--task 1
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    DateOfBirth DATE NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Account (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    AccountNumber VARCHAR(20) UNIQUE NOT NULL,
    CustomerID INT NOT NULL Foreign key References Customer(CustomerID) ,
    AccountType VARCHAR(10) CHECK (AccountType IN ('Savings', 'Current', 'Loan')) NOT NULL,
    Balance DECIMAL(18,2) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT NOT NULL,
    TransactionType VARCHAR(10) CHECK (TransactionType IN ('Credit', 'Debit')) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionDate DATETIME DEFAULT GETDATE(),
    Description VARCHAR(200) NULL,
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

CREATE TABLE Loan (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL,
    AccountID INT NOT NULL,
    LoanAmount DECIMAL(18,2) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
);

CREATE TABLE LoanPayment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    LoanID INT NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    Amount DECIMAL(18,2) NOT NULL,
    PaymentMethod VARCHAR(20) NOT NULL,
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID)
);

--task2 
CREATE TABLE AccountLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT NOT NULL,
    AccountNumber VARCHAR(20) NOT NULL,
    CustomerID INT NOT NULL,
    AccountType VARCHAR(10) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    LogCreatedAt DATETIME DEFAULT GETDATE() -- Timestamp of when the log entry was created
);

CREATE TRIGGER trg_LogNewAccount
ON Account
AFTER INSERT
AS
BEGIN
    INSERT INTO AccountLog (AccountID, AccountNumber, CustomerID, AccountType, CreatedAt)
    SELECT AccountID, AccountNumber, CustomerID, AccountType, CreatedAt
    FROM inserted;
END;

-- negative balance trigger
CREATE TRIGGER trg_PreventNegativeBalanceOnUpdate
ON Account
INSTEAD OF UPDATE
AS
BEGIN
    DECLARE @NewBalance DECIMAL(18, 2);
    DECLARE @AccountID INT;

    -- Get the updated balance and AccountID from the `inserted` pseudo-table
    SELECT @NewBalance = Balance, @AccountID = AccountID
    FROM inserted;

    -- Get the current balance from the `Account` table
    DECLARE @CurrentBalance DECIMAL(18, 2);
    SELECT @CurrentBalance = Balance
    FROM Account
    WHERE AccountID = @AccountID;

    -- Check if the update is a debit (reducing the balance)
    IF @NewBalance < @CurrentBalance
    BEGIN
        -- Check if the resulting balance is negative
        IF @NewBalance < 0
        BEGIN
            -- Prevent the update and raise an error
            RAISERROR('Withdrawal denied: Insufficient funds to complete the transaction.', 16, 1);
        END
        ELSE
        BEGIN
            -- Allow the update (i.e., debit) if it does not result in a negative balance
            UPDATE Account
            SET Balance = @NewBalance
            WHERE AccountID = @AccountID;
        END
    END
    ELSE
    BEGIN
        -- Allow updates that are credits or do not affect the balance negatively
        UPDATE Account
        SET Balance = @NewBalance
        WHERE AccountID = @AccountID;
    END
END;


--task 3 Functions

CREATE FUNCTION CalculateInterest (
    @Balance DECIMAL(18, 2),
    @AnnualInterestRate DECIMAL(5, 2) -- This should be in percentage, e.g., 3.5 for 3.5%
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @Interest DECIMAL(18, 2);

    -- Calculate the interest: (Balance * Annual Interest Rate) / 100
    SET @Interest = (@Balance * @AnnualInterestRate) / 100;

    RETURN @Interest;
END;

-- task4
CREATE PROCEDURE CreateNewAccount
    @CustomerID INT,
    @AccountNumber VARCHAR(20),
    @AccountType VARCHAR(10),
    @InitialBalance DECIMAL(18, 2)
AS
BEGIN
    -- Error handling: Ensure the CustomerID exists
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = @CustomerID)
    BEGIN
        RAISERROR('CustomerID does not exist.', 16, 1);
        RETURN;
    END

    -- Error handling: Ensure AccountType is valid
    IF @AccountType NOT IN ('Savings', 'Current', 'Loan')
    BEGIN
        RAISERROR('Invalid Account Type. Must be one of: Savings, Current, Loan.', 16, 1);
        RETURN;
    END

    -- Insert the new account
    INSERT INTO Account (AccountNumber, CustomerID, AccountType, Balance)
    VALUES (@AccountNumber, @CustomerID, @AccountType, @InitialBalance);

    -- Return the newly created AccountID
    DECLARE @NewAccountID INT;
    SET @NewAccountID = SCOPE_IDENTITY();

    -- Output the new AccountID
    SELECT @NewAccountID AS AccountID, 'Account created successfully.' AS Message;
END;


    --Procedure to deposit or transfer account

    CREATE PROCEDURE PerformTransaction
    @OperationType VARCHAR(10), -- 'Deposit', 'Withdraw', or 'Transfer'
    @AccountID INT,
    @Amount DECIMAL(18, 2),
    @DestinationAccountID INT = NULL -- Required only for transfers
AS
BEGIN
    -- Error handling: Ensure valid operation type
    IF @OperationType NOT IN ('Deposit', 'Withdraw', 'Transfer')
    BEGIN
        RAISERROR('Invalid OperationType. Must be one of: Deposit, Withdraw, Transfer.', 16, 1);
        RETURN;
    END

    -- Error handling: Ensure the AccountID exists
    IF NOT EXISTS (SELECT 1 FROM Account WHERE AccountID = @AccountID)
    BEGIN
        RAISERROR('Source AccountID does not exist.', 16, 1);
        RETURN;
    END

    -- For transfers, ensure the DestinationAccountID exists
    IF @OperationType = 'Transfer' AND NOT EXISTS (SELECT 1 FROM Account WHERE AccountID = @DestinationAccountID)
    BEGIN
        RAISERROR('Destination AccountID does not exist.', 16, 1);
        RETURN;
    END

    -- Error handling: Ensure the amount is positive
    IF @Amount <= 0
    BEGIN
        RAISERROR('Amount must be positive.', 16, 1);
        RETURN;
    END

    -- Perform the transaction
    IF @OperationType = 'Deposit'
    BEGIN
        -- Deposit: Add the amount to the account balance
        UPDATE Account
        SET Balance = Balance + @Amount
        WHERE AccountID = @AccountID;

        -- Optionally, you can log this transaction in a Transaction table
        INSERT INTO Transaction (AccountID, TransactionType, Amount, Description)
        VALUES (@AccountID, 'Credit', @Amount, 'Deposit');
    END
    ELSE IF @OperationType = 'Withdraw'
    BEGIN
        DECLARE @CurrentBalance DECIMAL(18, 2);
        SELECT @CurrentBalance = Balance FROM Account WHERE AccountID = @AccountID;

        -- Ensure there are sufficient funds for withdrawal
        IF @CurrentBalance < @Amount
        BEGIN
            RAISERROR('Insufficient funds for withdrawal.', 16, 1);
            RETURN;
        END

        -- Withdraw: Subtract the amount from the account balance
        UPDATE Account
        SET Balance = Balance - @Amount
        WHERE AccountID = @AccountID;

        -- Optionally, you can log this transaction in a Transaction table
        INSERT INTO Transaction (AccountID, TransactionType, Amount, Description)
        VALUES (@AccountID, 'Debit', @Amount, 'Withdrawal');
    END
    ELSE IF @OperationType = 'Transfer'
    BEGIN
        DECLARE @SourceBalance DECIMAL(18, 2);
        SELECT @SourceBalance = Balance FROM Account WHERE AccountID = @AccountID;

        -- Ensure there are sufficient funds for the transfer
        IF @SourceBalance < @Amount
        BEGIN
            RAISERROR('Insufficient funds for transfer.', 16, 1);
            RETURN;
        END

        -- Transfer: Subtract the amount from the source account and add it to the destination account
        BEGIN TRANSACTION;

        -- Debit from the source account
        UPDATE Account
        SET Balance = Balance - @Amount
        WHERE AccountID = @AccountID;

        -- Credit to the destination account
        UPDATE Account
        SET Balance = Balance + @Amount
        WHERE AccountID = @DestinationAccountID;

        -- Log the transfer in the Transaction table
        INSERT INTO Transaction (AccountID, TransactionType, Amount, Description)
        VALUES (@AccountID, 'Debit', @Amount, 'Transfer to Account ' + CAST(@DestinationAccountID AS VARCHAR));

        INSERT INTO Transaction (AccountID, TransactionType, Amount, Description)
        VALUES (@DestinationAccountID, 'Credit', @Amount, 'Transfer from Account ' + CAST(@AccountID AS VARCHAR));

        COMMIT TRANSACTION;
    END

    PRINT 'Transaction completed successfully.';
END;

-- loan payment

CREATE PROCEDURE ApplyLoanPayment
    @LoanAccountID INT, -- AccountID of the loan account
    @PaymentAmount DECIMAL(18, 2)
AS
BEGIN
    -- Error handling: Ensure the LoanAccountID exists and is of type 'Loan'
    IF NOT EXISTS (SELECT 1 FROM Account WHERE AccountID = @LoanAccountID AND AccountType = 'Loan')
    BEGIN
        RAISERROR('Invalid Loan Account ID. Please provide a valid Loan Account.', 16, 1);
        RETURN;
    END

    -- Error handling: Ensure the payment amount is positive
    IF @PaymentAmount <= 0
    BEGIN
        RAISERROR('Payment amount must be positive.', 16, 1);
        RETURN;
    END

    -- Get the current loan balance
    DECLARE @CurrentLoanBalance DECIMAL(18, 2);
    SELECT @CurrentLoanBalance = Balance
    FROM Account
    WHERE AccountID = @LoanAccountID;

    -- Ensure the payment does not exceed the loan balance
    IF @PaymentAmount > @CurrentLoanBalance
    BEGIN
        RAISERROR('Payment amount exceeds the outstanding loan balance.', 16, 1);
        RETURN;
    END

    -- Apply the payment: Reduce the loan balance by the payment amount
    UPDATE Account
    SET Balance = Balance - @PaymentAmount
    WHERE AccountID = @LoanAccountID;

    -- Log the payment in the Transaction table
    INSERT INTO Transaction (AccountID, TransactionType, Amount, Description)
    VALUES (@LoanAccountID, 'Credit', @PaymentAmount, 'Loan Payment');

    -- Check if the loan is fully paid off
    SELECT @CurrentLoanBalance = Balance
    FROM Account
    WHERE AccountID = @LoanAccountID;

    IF @CurrentLoanBalance = 0
    BEGIN
        PRINT 'Loan fully paid off. Congratulations!';
    END

    PRINT 'Loan payment applied successfully.';
END;
