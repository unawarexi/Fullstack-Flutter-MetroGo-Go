import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _darkMode = true;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;
  bool _emergencyContactEnabled = true;

  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Alex Johnson',
    'email': 'alex.johnson@example.com',
    'phone': '+1 (555) 123-4567',
    'profileImage': 'assets/profile_pic.jpg',
    'rating': 4.8,
    'totalRides': 142,
    'memberSince': 'March 2023',
    'preferredPayment': 'Visa •••• 4582',
    'savedLocations': [
      {'name': 'Home', 'address': '123 Main St, Anytown, CA'},
      {'name': 'Work', 'address': '456 Office Park, Business City, CA'},
      {'name': 'Gym', 'address': '789 Fitness Ave, Healthyville, CA'},
    ],
    'recentTrips': [
      {
        'date': 'Mar 20, 2025',
        'from': 'Home',
        'to': 'Work',
        'price': '\$12.50',
        'driverName': 'Michael Smith',
        'driverRating': 4.9,
      },
      {
        'date': 'Mar 18, 2025',
        'from': 'Work',
        'to': 'Gym',
        'price': '\$8.75',
        'driverName': 'Sarah Davis',
        'driverRating': 4.7,
      },
      {
        'date': 'Mar 15, 2025',
        'from': 'Gym',
        'to': 'Home',
        'price': '\$10.25',
        'driverName': 'Robert Johnson',
        'driverRating': 4.8,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildTabBar(),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPreferencesTab(isDarkMode),
                  _buildSecurityTab(isDarkMode),
                  _buildActivityTab(isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black, 
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade900,
                Colors.purple.shade800,
                Colors.purple.shade700,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.qr_code_scanner, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR Code Scanner'),
                backgroundColor: Colors.purple,
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit Profile'),
                backgroundColor: Colors.purple,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['name'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData['email'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7), 
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData['phone'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7), 
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_userData['rating']}',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: Colors.purple,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_userData['totalRides']} rides',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(
                icon: Icons.payment,
                title: 'Payment',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Manage Payment Methods'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              _buildQuickAction(
                icon: Icons.support_agent,
                title: 'Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact Support'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              _buildQuickAction(
                icon: Icons.favorite,
                title: 'Favorites',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View Favorite Places'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
              _buildQuickAction(
                icon: Icons.local_offer,
                title: 'Promos',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('View Promotions'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return GestureDetector(
     
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.purple,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Colors.purple,
        labelColor: Colors.purple,
        unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.black54,
        tabs: const [
          Tab(text: 'Preferences'),
          Tab(text: 'Security'),
          Tab(text: 'Activity'),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('App Settings'),
          _buildSettingsCard([
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Use dark theme across the app',
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Receive ride updates and promotions',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Language',
              subtitle: 'English (US)',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => _buildLanguageSelector(),
                );
              },
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Currency',
              subtitle: 'USD (\$)',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => _buildCurrencySelector(),
                );
              },
            ),
          ]),
          _buildSectionHeader('Ride Preferences'),
          _buildSettingsCard([
            _buildTapTile(
              title: 'Preferred Vehicle Type',
              subtitle: 'Standard, Premium, XL',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Set preferred vehicle types'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Favorite Drivers',
              subtitle: '3 drivers added to favorites',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View favorite drivers'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Saved Locations',
              subtitle: 'Home, Work, Gym',
              onTap: () {
                _showSavedLocationsSheet();
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: 'Work Profile',
              subtitle: 'Enable business travel features',
              value: false,
              onChanged: (value) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Business profile settings'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
          ]),
          _buildSectionHeader('Payment Methods'),
          _buildSettingsCard([
            _buildPaymentMethodTile(
              title: 'Visa •••• 4582',
              icon: Icons.credit_card,
              isDefault: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manage Visa card'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildPaymentMethodTile(
              title: 'PayPal',
              icon: Icons.account_balance_wallet,
              isDefault: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manage PayPal'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Add Payment Method',
              subtitle: 'Credit card, PayPal, Apple Pay',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add new payment method'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              trailing: const Icon(
                Icons.add_circle_outline,
                color: Colors.purple,
              ),
            ),
          ]),
          const SizedBox(height: 100), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildSecurityTab(bool isDarkMode) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Account Security'),
          _buildSettingsCard([
            _buildTapTile(
              title: 'Change Password',
              subtitle: 'Last changed 2 months ago',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password screen'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode ? Colors.white54 : Colors.black54,
                size: 16,
              ),
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: '2-Factor Authentication',
              subtitle: 'Add an extra layer of security',
              value: _twoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  _twoFactorEnabled = value;
                });
                if (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Setting up 2FA'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                }
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face ID',
              value: _biometricEnabled,
              onChanged: (value) {
                setState(() {
                  _biometricEnabled = value;
                });
              },
            ),
          ]),
          _buildSectionHeader('Privacy'),
          _buildSettingsCard([
            _buildSwitchTile(
              title: 'Location Services',
              subtitle: 'Allow app to access your location',
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Data Sharing',
              subtitle: 'Manage how your data is used',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data sharing preferences'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Delete Account',
              subtitle: 'Permanently remove your data',
              onTap: () {
                _showDeleteAccountDialog();
              },
              trailing: const Icon(
                Icons.warning_amber,
                color: Colors.red,
                size: 16,
              ),
            ),
          ]),
          _buildSectionHeader('Ride Safety'),
          _buildSettingsCard([
            _buildSwitchTile(
              title: 'Share Ride Status',
              subtitle: 'Let trusted contacts follow your ride',
              value: true,
              onChanged: (value) {
                setState(() {});
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: 'Emergency Contacts',
              subtitle: 'Quick access to emergency contacts',
              value: _emergencyContactEnabled,
              onChanged: (value) {
                setState(() {
                  _emergencyContactEnabled = value;
                });
              },
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Trusted Contacts',
              subtitle: 'Manage people who can see your rides',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manage trusted contacts'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ),
            _buildDivider(),
            _buildTapTile(
              title: 'Emergency SOS',
              subtitle: 'Configure emergency assistance',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency SOS settings'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ),
          ]),
          const SizedBox(height: 100), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildActivityTab(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Account Summary'),
          _buildSummaryCard(),
          _buildSectionHeader('Recent Trips'),
          ..._userData['recentTrips'].map<Widget>((trip) => _buildTripCard(trip)).toList(),
          const SizedBox(height: 20),
          _buildViewAllButton('View All Trips'),
          _buildSectionHeader('Ride Statistics'),
          _buildStatsCard(),
          _buildSectionHeader('Rewards & Referrals'),
          _buildRewardsCard(),
          const SizedBox(height: 100), // Bottom spacing
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                icon: Icons.calendar_today,
                title: 'Member Since',
                value: _userData['memberSince'],
              ),
              _buildSummaryItem(
                icon: Icons.directions_car,
                title: 'Total Rides',
                value: '${_userData['totalRides']}',
              ),
              _buildSummaryItem(
                icon: Icons.star,
                title: 'Rating',
                value: '${_userData['rating']}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.purple,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_car,
            color: Colors.purple,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${trip['from']} to ${trip['to']}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              trip['price'],
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              trip['date'],
              style: TextStyle(
                color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Driver: ${trip['driverName']}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 12,
                ),
                Text(
                  '${trip['driverRating']}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDarkMode ? Colors.white54 : Colors.black54,
          size: 16,
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trip details for ${trip['date']}'),
              backgroundColor: Colors.purple,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildStatRow('Total Distance', '487.2 miles'),
          const SizedBox(height: 10),
          _buildStatRow('Average Trip Length', '3.4 miles'),
          const SizedBox(height: 10),
          _buildStatRow('Most Used Service', 'Standard Ride (78%)'),
          const SizedBox(height: 10),
          _buildStatRow('Common Destination', 'Work (42 rides)'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View detailed statistics'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.purple),
              foregroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View Detailed Stats'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, String value) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7), 
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsCard() {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade900,
            Colors.purple.shade800,
            Colors.purple.shade700,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: isDarkMode ? Colors.white : Colors.purple,
                size: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                'DatRide Rewards',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You have 750 points',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.75,
              backgroundColor: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.purple.withOpacity(0.2), 
              color: Colors.white,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '250 more points to reach Gold',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Silver Member',
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Viewing rewards catalog'),
                  backgroundColor: Colors.deepPurple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Center(
              child: Text(
                'View Rewards Catalog',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share referral code to earn points'),
                  backgroundColor: Colors.deepPurple,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Center(
              child: Text(
                'Invite Friends & Earn 100 Points',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(String text) {
    // final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              backgroundColor: Colors.purple,
            ),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: Colors.purple,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildTapTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                  size: 16,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required IconData icon,
    required bool isDefault,
    required VoidCallback onTap,
  }) {
    final isDarkMode =  THelperFunctions.isDarkMode(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  if (isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Text(
                    'Set as Default',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text(
                    'Edit',
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
              onSelected: (value) {
                String message = 'Default action';
                if (value == 1) {
                  message = 'Set as default payment method';
                } else if (value == 2) {
                  message = 'Edit payment method';
                } else if (value == 3) {
                  message = 'Remove payment method';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade800,
      height: 1,
    );
  }

  void _showSavedLocationsSheet() {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saved Locations',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Add new location'),
                            backgroundColor: Colors.purple,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade800, height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _userData['savedLocations'].length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade800,
                    height: 16,
                  ),
                  itemBuilder: (context, index) {
                    final location = _userData['savedLocations'][index];
                    return _buildLocationTile(location);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationTile(Map<String, dynamic> location) {
    IconData iconData = Icons.home;
    if (location['name'] == 'Work') {
      iconData = Icons.work;
    } else if (location['name'] == 'Gym') {
      iconData = Icons.fitness_center;
    }
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: Colors.purple,
          size: 24,
        ),
      ),
      title: Text(
        location['name'],
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        location['address'],
        style: TextStyle(
          color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: isDarkMode ? Colors.white70 : Colors.black54),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Edit ${location['name']}'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: isDarkMode ? Colors.white70 : Colors.black54),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Remove ${location['name']}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final languages = [
      'English (US)',
      'Spanish',
      'French',
      'German',
      'Chinese',
      'Japanese',
      'Arabic',
      'Russian',
      'Portuguese',
      'Hindi',
    ];
//  final isDarkMode = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select Language',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(color: Colors.grey.shade800, height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final isSelected = languages[index] == 'English (US)';
              return ListTile(
                title: Text(
                  languages[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.purple,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (!isSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Language set to ${languages[index]}'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencySelector() {
    final currencies = [
      'USD (\$)',
      'EUR (€)',
      'GBP (£)',
      'JPY (¥)',
      'AUD (\$)',
      'CAD (\$)',
      'CHF (Fr)',
      'CNY (¥)',
      'INR (₹)',
      'BRL (R\$)',
    ];
  // final isDarkMode = THelperFunctions.isDarkMode(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Select Currency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(color: Colors.grey.shade800, height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final isSelected = currencies[index] == 'USD (\$)';
              return ListTile(
                title: Text(
                  currencies[index],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.purple,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  if (!isSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Currency set to ${currencies[index]}'),
                        backgroundColor: Colors.purple,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account? This action cannot be undone and you will lose:',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              _buildDeleteBulletPoint('All your saved locations'),
              _buildDeleteBulletPoint('Ride history and ratings'),
              _buildDeleteBulletPoint('Payment methods'),
              _buildDeleteBulletPoint('Reward points (750 points)'),
              const SizedBox(height: 16),
              TextField(
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Type "DELETE" to confirm',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5)),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion initiated'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteBulletPoint(String text) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.remove_circle,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}