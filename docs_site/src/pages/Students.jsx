import React from 'react';

const Students = () => {
  return (
    <div>
      <h1>Student Management</h1>
      <p>
        The Students section allows you to manage the student database.
      </p>

      <h2>Viewing Students</h2>
      <p>
        Navigate to the <strong>Students</strong> tab to see a list of all students. You can search for students by name or ID.
      </p>

      <h2>Adding a Student</h2>
      <ol>
        <li>Click the <strong>Add Student</strong> button (usually a '+' icon).</li>
        <li>Fill in the student's personal information:
          <ul>
            <li>Full Name</li>
            <li>Date of Birth</li>
            <li>Contact Information</li>
            <li>Grade/Class</li>
          </ul>
        </li>
        <li>Save the record.</li>
      </ol>

      <h2>Student Profile</h2>
      <p>
        Clicking on a student's name takes you to their profile. Here you can see:
      </p>
      <ul>
        <li>Personal details</li>
        <li>Fee history (Invoices and Payments)</li>
        <li>Attendance (if applicable)</li>
      </ul>

      <h2>Editing/Deleting</h2>
      <p>
        You can edit a student's details or delete a record if necessary from their profile page or the main list view action menu.
      </p>
    </div>
  );
};

export default Students;
