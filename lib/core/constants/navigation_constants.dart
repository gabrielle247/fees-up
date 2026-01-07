import 'package:flutter/material.dart';
import '../../data/models/navigation/sidebar_item_model.dart';

class NavigationConstants {
  // GROUP 1: OPERATIONAL (Day-to-day Management)
  static const List<SidebarItemModel> operationalItems = [
    SidebarItemModel(icon: Icons.grid_view_rounded, label: 'Overview', route: '/'),
    SidebarItemModel(icon: Icons.receipt_long_rounded, label: 'Transactions', route: '/transactions'),
    SidebarItemModel(icon: Icons.description_outlined, label: 'Invoices', route: '/invoices'),
    SidebarItemModel(icon: Icons.school_outlined, label: 'Students', route: '/students'),
    SidebarItemModel(icon: Icons.bar_chart_rounded, label: 'Reports', route: '/reports'),
  ];

  // GROUP 2: MESSAGING (Communication Hub)
  static const List<SidebarItemModel> messagingItems = [
    SidebarItemModel(icon: Icons.campaign_outlined, label: 'Broadcasts', route: '/announcements'), // System-wide
    SidebarItemModel(icon: Icons.notifications_none_rounded, label: 'Notifications', route: '/notifications'), // Personal
  ];
}
