import React from 'react';

const Introduction = () => {
  return (
    <div>
      <h1>Introduction to Fees Up</h1>
      <p>
        Welcome to the official documentation for <strong>Fees Up</strong>, a comprehensive student fees management application.
      </p>

      <p>
        Fees Up is designed to streamline the financial operations of educational institutions, allowing administrators to easily manage student profiles, track fee payments, generate invoices, and view financial reports.
      </p>

      <h2>Key Features</h2>
      <ul>
        <li><strong>Multi-Platform Support</strong>: Access your data from both Mobile and PC.</li>
        <li><strong>Student Management</strong>: Create and manage student records with ease.</li>
        <li><strong>Invoicing</strong>: Generate and track invoices for tuition and other fees.</li>
        <li><strong>Transaction Tracking</strong>: Record payments and maintain a financial history.</li>
        <li><strong>Offline Capability</strong>: Thanks to PowerSync, work offline and sync when you're back online.</li>
        <li><strong>Secure</strong>: Built with Supabase for secure data handling and authentication.</li>
      </ul>

      <div className="tip-box">
        <strong>Note:</strong> This documentation covers both the Mobile and PC versions of the application, with a focus on the PC dashboard for administrative tasks.
      </div>
    </div>
  );
};

export default Introduction;
