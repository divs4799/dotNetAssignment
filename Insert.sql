INSERT INTO Customer (FirstName, LastName, Email, PhoneNumber, Address, DateOfBirth)
VALUES 
('Abhishek', 'Singh', 'abhishek@example.com', '1234567890', '123 Main St', '1990-05-15'),
('Bikash', 'Rana', 'bikash@example.com', '1234567891', '456 Oak St', '1989-08-20'),
('Divyansh', 'Kumar', 'divyansh@example.com', '1234567892', '789 Pine St', '1995-11-05'),
('Aradhita', 'Sharma', 'aradhita@example.com', '1234567893', '321 Elm St', '1992-01-10'),
('Mahak', 'Jain', 'mahak@example.com', '1234567894', '654 Cedar St', '1993-02-22'),
('Nikhil', 'Gupta', 'nikhil@example.com', '1234567895', '987 Birch St', '1996-04-30'),
('Aashrita', 'Reddy', 'aashrita@example.com', '1234567896', '159 Willow St', '1994-07-12');


INSERT INTO Account (AccountNumber, CustomerID, AccountType, Balance)
VALUES 
('ACC12345', 1, 'Savings', 5000.00),
('ACC12346', 2, 'Current', 10000.00),
('ACC12347', 3, 'Savings', 7500.00),
('ACC12348', 4, 'Savings', 2000.00),
('ACC12349', 5, 'Current', 15000.00),
('ACC12350', 6, 'Savings', 6000.00),
('ACC12351', 7, 'Savings', 8000.00);

INSERT INTO Transaction (AccountID, TransactionType, Amount, Description)
VALUES 
(1, 'Credit', 1000.00, 'Salary Credit'),
(2, 'Debit', 500.00, 'ATM Withdrawal'),
(3, 'Credit', 2000.00, 'Freelance Payment'),
(4, 'Debit', 300.00, 'Grocery Shopping'),
(5, 'Credit', 1500.00, 'Investment Return'),
(6, 'Debit', 200.00, 'Restaurant Bill'),
(7, 'Credit', 1000.00, 'Gift Received');

INSERT INTO Loan (CustomerID, AccountID, LoanAmount, InterestRate, StartDate, EndDate)
VALUES 
(1, 1, 10000.00, 7.5, '2024-01-01', '2025-01-01'),
(2, 2, 20000.00, 8.0, '2024-02-01', '2026-02-01'),
(3, 3, 15000.00, 7.0, '2024-03-01', '2025-03-01');

INSERT INTO LoanPayment (LoanID, Amount, PaymentMethod)
VALUES 
(1, 1000.00, 'Online Transfer'),
(2, 1500.00, 'Cash'),
(3, 1200.00, 'Cheque');
