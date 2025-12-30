import React from 'react';

const Settings = () => {
  return (
    <div>
      <h1>Settings</h1>
      <p>
        The Settings area allows you to customize the application and manage your account preferences.
      </p>

      <h2>Institution Profile</h2>
      <p>
        Here you can view and update details about your school or institution.
      </p>
      <ul>
        <li><strong>Name & Address</strong>: Ensure these are correct as they appear on invoices and reports.</li>
        <li><strong>Logo</strong>: Upload your school logo to brand your documents.</li>
        <li><strong>Contact Info</strong>: Phone numbers and emails for support inquiries.</li>
      </ul>

      <h2>General Preferences</h2>
      <ul>
        <li><strong>Currency</strong>: Verify the currency symbol (e.g., $, €, £) used for all fee transactions.</li>
        <li><strong>Notifications</strong>: Choose how you want to be notified about payments or overdue invoices (Email, SMS, or In-App).</li>
      </ul>

      <h2>Data Synchronization</h2>
      <p>
        Fees Up works offline, but you need to sync with the cloud to ensure data is safe and accessible on other devices.
      </p>
      <ul>
        <li><strong>Sync Status</strong>: Shows if your data is up-to-date.</li>
        <li><strong>Last Sync</strong>: The timestamp of the last successful backup.</li>
      </ul>
      <div className="tip-box">
        <strong>Tip:</strong> The app automatically syncs when you are online. If you see a "Sync Error", check your internet connection and try again.
      </div>

      <h2>Security</h2>
      <ul>
        <li><strong>Change Password</strong>: Update your login password periodically for security.</li>
        <li><strong>Biometric Login</strong>: On mobile devices, you can enable Fingerprint or Face ID for quicker access.</li>
      </ul>
    </div>
  );
};

export default Settings;
