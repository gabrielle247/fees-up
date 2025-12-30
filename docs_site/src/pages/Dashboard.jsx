import React from 'react';

const Dashboard = () => {
  return (
    <div className="docs-content">
      <h1 style={{ color: 'var(--accent-blue)', fontSize: '2.5rem', marginBottom: '8px' }}>
        Financial Dashboard
      </h1>
      <p style={{ fontSize: '1.1rem', color: 'var(--text-dim)', marginBottom: '32px' }}>
        Status for Cores Point HQ
      </p>

      {/* SECTION 1: TOP KPI CARDS */}
      <section style={{ marginBottom: '48px' }}>
        <h2 style={{ fontSize: '1.5rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '8px' }}>
          Overview Insights
        </h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '20px', marginTop: '20px' }}>
          
          <div className="doc-card">
            <h4 style={{ color: 'var(--text-dim)', textTransform: 'uppercase', fontSize: '0.8rem' }}>Outstanding Bills</h4>
            <p style={{ fontSize: '1.8rem', fontWeight: '700', margin: '10px 0' }}>$400.00</p>
            <span style={{ color: '#ff5252', fontSize: '0.85rem' }}>⚠️ Updated Just now</span>
          </div>

          <div className="doc-card">
            <h4 style={{ color: 'var(--text-dim)', textTransform: 'uppercase', fontSize: '0.8rem' }}>Campaigns & Bonuses</h4>
            <p style={{ fontSize: '1.8rem', fontWeight: '700', margin: '10px 0' }}>0.0%</p>
            <span style={{ color: 'var(--text-dim)', fontSize: '0.85rem' }}>Raised $0 of $100</span>
          </div>

          <div className="doc-card">
            <h4 style={{ color: 'var(--text-dim)', textTransform: 'uppercase', fontSize: '0.8rem' }}>Active Students</h4>
            <p style={{ fontSize: '1.8rem', fontWeight: '700', margin: '10px 0' }}>14</p>
            <span style={{ color: 'var(--text-dim)', fontSize: '0.85rem' }}>Enrolled</span>
          </div>
          
        </div>
      </section>

      {/* SECTION 2: CHARTS & ACTIONS */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '30px', marginBottom: '48px' }}>
        
        <section>
          <h2>Revenue & Collections</h2>
          <p style={{ color: 'var(--text-dim)' }}>
            The central chart provides a weekly breakdown of incoming funds. Use the filter toggle 
            to switch between **Weekly**, **Monthly**, or **Termly** views.
          </p>
          <div style={{ background: 'rgba(255,255,255,0.02)', height: '200px', border: '1px dashed var(--border-color)', borderRadius: '12px', marginTop: '15px', display: 'flex', alignItems: 'center', justifyCenter: 'center' }}>
             <p style={{ width: '100%', textAlign: 'center', color: 'var(--text-dim)' }}>[Revenue Analytics Visualization]</p>
          </div>
        </section>

        <section>
          <h2>Quick Actions</h2>
          <p style={{ color: 'var(--text-dim)', marginBottom: '15px' }}>Direct access to core financial tools:</p>
          <ul style={{ listStyle: 'none', padding: 0, display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <li><strong>🟢 Record Payment:</strong> Log tuition or supply fees.</li>
            <li><strong>🔴 Add Expense:</strong> Track outgoing school costs.</li>
            <li><strong>👤 New Student:</strong> Fast-track enrollment.</li>
            <li><strong>📢 New Campaign:</strong> Launch a fundraiser or bonus drive.</li>
          </ul>
        </section>

      </div>

      {/* SECTION 3: RECENT ACTIVITY */}
      <section>
        <h2>Recent Payments</h2>
        <p style={{ color: 'var(--text-dim)', marginBottom: '20px' }}>
          A live audit log of the most recent transactions processed across the institution.
        </p>
        <div style={{ background: 'var(--bg-secondary)', padding: '20px', borderRadius: '12px' }}>
          <p><strong>Paid Status:</strong> Invoices marked in <span style={{ color: '#4CAF50' }}>Green</span> are fully reconciled.</p>
          <p><strong>Tracking:</strong> Each entry logs the Payer (Student Name), Purpose (Tuition/Uniform), and the exact Timestamp.</p>
        </div>
      </section>
    </div>
  );
};

export default Dashboard;