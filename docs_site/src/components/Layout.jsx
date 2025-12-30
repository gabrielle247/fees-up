import React from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import './Layout.css';

const Layout = () => {
  return (
    <div className="docs-wrapper">
      <aside className="docs-sidebar">
        {/* Profile Section (Matching your top-right profile in app) */}
        <div className="sidebar-profile">
          <div className="profile-icon">NG</div>
          <div className="profile-info">
            <span className="user-name">Nyasha Gabriel</span>
            <span className="user-role">Cores Point HQ</span>
          </div>
        </div>

        <nav className="sidebar-group">
          <NavLink to="/dashboard" className="nav-item"><span>📊</span> Overview</NavLink>
          <NavLink to="/transactions" className="nav-item"><span>💳</span> Transactions</NavLink>
          <NavLink to="/invoices" className="nav-item"><span>📄</span> Invoices</NavLink>
          <NavLink to="/students" className="nav-item"><span>👥</span> Students</NavLink>
          <NavLink to="/reports" className="nav-item"><span>📈</span> Reports</NavLink>
        </nav>

        <div className="group-label">MESSAGING</div>
        <nav className="sidebar-group">
          <NavLink to="/broadcasts" className="nav-item"><span>📢</span> Broadcasts</NavLink>
          <NavLink to="/notifications" className="nav-item"><span>🔔</span> Notifications</NavLink>
        </nav>

        <div className="group-label">PREFERENCES</div>
        <nav className="sidebar-group">
          <NavLink to="/profile" className="nav-item"><span>👤</span> Profile</NavLink>
          <NavLink to="/settings" className="nav-item"><span>⚙️</span> Settings</NavLink>
        </nav>

        <div className="sidebar-footer">
          <button className="logout-btn"><span>🚪</span> Log Out</button>
        </div>
      </aside>

      <main className="docs-main">
        <header className="docs-header">
          <span className="breadcrumb">Docs / Financial Dashboard</span>
        </header>
        <div className="docs-body">
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default Layout;