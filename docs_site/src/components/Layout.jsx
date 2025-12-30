import React from 'react';
import { Link, Outlet, useLocation } from 'react-router-dom';
import { Book, Home, Users, FileText, CreditCard, BarChart, Settings, Menu } from 'lucide-react';
import './Layout.css';

const Layout = () => {
  const location = useLocation();
  const [isMobileMenuOpen, setIsMobileMenuOpen] = React.useState(false);

  const navItems = [
    { path: '/', label: 'Introduction', icon: <Book size={20} /> },
    { path: '/getting-started', label: 'Getting Started', icon: <Home size={20} /> },
    { path: '/dashboard', label: 'Dashboard', icon: <BarChart size={20} /> },
    { path: '/students', label: 'Students', icon: <Users size={20} /> },
    { path: '/invoices', label: 'Invoices', icon: <FileText size={20} /> },
    { path: '/transactions', label: 'Transactions', icon: <CreditCard size={20} /> },
    { path: '/reports', label: 'Reports', icon: <BarChart size={20} /> },
    { path: '/settings', label: 'Settings', icon: <Settings size={20} /> },
  ];

  return (
    <div className="app-container">
      <header className="mobile-header">
        <h1>Fees Up Docs</h1>
        <button onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}>
          <Menu />
        </button>
      </header>

      <aside className={`sidebar ${isMobileMenuOpen ? 'open' : ''}`}>
        <div className="sidebar-header">
          <h2>Fees Up Docs</h2>
        </div>
        <nav>
          <ul>
            {navItems.map((item) => (
              <li key={item.path} className={location.pathname === item.path ? 'active' : ''}>
                <Link to={item.path} onClick={() => setIsMobileMenuOpen(false)}>
                  {item.icon}
                  <span>{item.label}</span>
                </Link>
              </li>
            ))}
          </ul>
        </nav>
      </aside>

      <main className="content">
        <div className="content-container">
          <Outlet />
        </div>
      </main>
    </div>
  );
};

export default Layout;
