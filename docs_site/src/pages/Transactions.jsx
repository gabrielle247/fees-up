import React from 'react';

const Transactions = () => {
  return (
    <div>
      <h1>Transactions</h1>
      <p>
        The Transactions section records all financial inflows (payments).
      </p>

      <h2>Recording a Payment</h2>
      <p>
        When a student pays their fees, you record it here:
      </p>
      <ol>
        <li>Go to <strong>Transactions</strong> or do this from the Student/Invoice view.</li>
        <li>Click <strong>Record Payment</strong>.</li>
        <li>Select the Student and the specific Invoice being paid.</li>
        <li>Enter the Amount Paid.</li>
        <li>Select the Payment Method (Cash, Bank Transfer, Card, etc.).</li>
        <li>Save the transaction.</li>
      </ol>

      <h2>Transaction History</h2>
      <p>
        You can view a chronological list of all payments received. This is useful for daily reconciliation.
      </p>
    </div>
  );
};

export default Transactions;
