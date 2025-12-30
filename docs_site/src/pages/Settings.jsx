import React from 'react';

const Settings = () => {
  return (
    <div>
      <h1>Settings</h1>
      <p>
        Configure the application to suit your institution's needs.
      </p>

      <h2>General Settings</h2>
      <ul>
        <li><strong>Institution Details</strong>: Name, Address, Logo, and Contact Info.</li>
        <li><strong>Currency</strong>: Set the default currency for financial transactions.</li>
      </ul>

      <h2>User Management</h2>
      <p>
        Manage staff accounts and permissions. You can create different roles (e.g., Admin, Accountant, Viewer) to control access to sensitive data.
      </p>

      <h2>Backup & Sync</h2>
      <p>
        Check the status of your data synchronization. The app uses PowerSync to keep data consistent across devices. Ensure you are connected to the internet periodically to sync local changes to the cloud.
      </p>
    </div>
  );
};

export default Settings;
