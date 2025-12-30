import React from 'react';

const GettingStarted = () => {
  return (
    <div>
      <h1>Getting Started</h1>

      <h2>System Requirements</h2>
      <p>
        Fees Up is a cross-platform application.
      </p>
      <ul>
        <li><strong>PC</strong>: Windows, macOS, or Linux.</li>
        <li><strong>Mobile</strong>: Android or iOS device.</li>
      </ul>

      <h2>Installation</h2>
      <p>
        Currently, Fees Up is distributed as a standalone application. Please contact your administrator or the IT department to get the latest installer for your device.
      </p>

      <h2>Authentication</h2>
      <p>
        To access the system, you need a valid account.
      </p>

      <h3>Logging In</h3>
      <ol>
        <li>Open the Fees Up application.</li>
        <li>You will be presented with the Login screen.</li>
        <li>Enter your registered <strong>Email</strong> and <strong>Password</strong>.</li>
        <li>Click the <strong>Login</strong> button.</li>
      </ol>

      <h3>Sign Up</h3>
      <p>
        If you do not have an account, you can create one if your institution allows it:
      </p>
      <ol>
        <li>On the Login screen, click on "Create an account" or "Sign Up".</li>
        <li>Fill in the required details (Name, Email, Password).</li>
        <li>Submit the form. You may need to verify your email address.</li>
      </ol>

      <div className="tip-box">
        If you have trouble logging in, please contact support or reset your password using the "Forgot Password" link.
      </div>
    </div>
  );
};

export default GettingStarted;
