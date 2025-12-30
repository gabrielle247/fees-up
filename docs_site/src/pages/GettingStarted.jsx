import React from 'react';

const GettingStarted = () => {
  return (
    <div>
      <h1>Getting Started</h1>

      <p>
        Welcome to Fees Up! This guide will help you log in and set up your account so you can start managing student fees effectively.
      </p>

      <h2>Accessing the Application</h2>
      <p>
        Fees Up is available on both your computer (Windows, macOS, Linux) and mobile device (Android, iOS).
      </p>

      <h2>Logging In</h2>
      <p>
        To access your dashboard, you need to log in with your registered account credentials.
      </p>

      <h3>Steps to Log In</h3>
      <ol>
        <li>Open the <strong>Fees Up</strong> application on your device.</li>
        <li>You will see the Login screen.</li>
        <li>Enter your <strong>Email Address</strong>.</li>
        <li>Enter your <strong>Password</strong>.</li>
        <li>Click or tap the <strong>Login</strong> button.</li>
      </ol>

      <div className="tip-box">
        <strong>Forgot Password?</strong> If you cannot remember your password, click the "Forgot Password?" link on the login screen to reset it via email.
      </div>

      <h3>First Time Login</h3>
      <p>
        If this is your first time using the app:
      </p>
      <ul>
        <li>Ensure you have internet connection to sync the initial data.</li>
        <li>Review your profile settings to ensure your information is correct.</li>
      </ul>

      <h2>Sign Up (New Users)</h2>
      <p>
        If your institution allows self-registration:
      </p>
      <ol>
        <li>Click <strong>Create an Account</strong> on the login screen.</li>
        <li>Fill in your full name, email address, and a strong password.</li>
        <li>Tap <strong>Sign Up</strong>.</li>
      </ol>
    </div>
  );
};

export default GettingStarted;
