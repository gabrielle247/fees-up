import React from 'react';

const Dashboard = () => {
  return (
    <div>
      <h1>Dashboard</h1>
      <p>
        The Dashboard is your command center. Once logged in, you are greeted with an overview of the institution's financial health.
      </p>

      <h2>Overview Cards</h2>
      <p>
        At the top of the dashboard, you will typically find summary cards displaying key metrics:
      </p>
      <ul>
        <li><strong>Total Students</strong>: The total number of active students registered.</li>
        <li><strong>Total Fees Collected</strong>: The sum of all payments received.</li>
        <li><strong>Pending Fees</strong>: The total amount outstanding from invoices.</li>
      </ul>

      <h2>Quick Actions</h2>
      <p>
        The dashboard often provides shortcuts to common tasks:
      </p>
      <ul>
        <li>Add a new Student</li>
        <li>Create an Invoice</li>
        <li>Record a Payment</li>
      </ul>

      <h2>Recent Activity</h2>
      <p>
        A list of recent transactions or system activities may be displayed, helping you stay up-to-date with the latest changes.
      </p>
    </div>
  );
};

export default Dashboard;
