import React from 'react';

const Invoices = () => {
  return (
    <div>
      <h1>Invoices</h1>
      <p>
        Invoices are formal requests for payment issued to students or their guardians.
      </p>

      <h2>Creating an Invoice</h2>
      <ol>
        <li>Navigate to the <strong>Invoices</strong> section.</li>
        <li>Click <strong>New Invoice</strong>.</li>
        <li>Select the student(s) to invoice.</li>
        <li>Add line items (e.g., Tuition Fee, Library Fee, Uniform).</li>
        <li>Set the Due Date.</li>
        <li>Save/Send the invoice.</li>
      </ol>

      <h2>Invoice Status</h2>
      <p>Invoices can have different statuses:</p>
      <ul>
        <li><strong>Unpaid</strong>: Payment is pending.</li>
        <li><strong>Partial</strong>: Some amount has been paid.</li>
        <li><strong>Paid</strong>: Full amount has been received.</li>
        <li><strong>Overdue</strong>: The due date has passed without full payment.</li>
      </ul>
    </div>
  );
};

export default Invoices;
