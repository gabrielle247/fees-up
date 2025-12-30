import React from 'react';

const Reports = () => {
  return (
    <div>
      <h1>Reports</h1>
      <p>
        Generate detailed financial reports to analyze the institution's performance.
      </p>

      <h2>Available Reports</h2>
      <ul>
        <li><strong>Fee Collection Report</strong>: Daily, weekly, or monthly collection summaries.</li>
        <li><strong>Outstanding Fees</strong>: A list of all overdue payments.</li>
        <li><strong>Student Statements</strong>: Individual financial history for a student.</li>
      </ul>

      <h2>Exporting</h2>
      <p>
        Most reports can be exported to PDF or Excel/CSV formats for offline analysis or printing. Look for the "Export" or "Print" button on the report screen.
      </p>
    </div>
  );
};

export default Reports;
