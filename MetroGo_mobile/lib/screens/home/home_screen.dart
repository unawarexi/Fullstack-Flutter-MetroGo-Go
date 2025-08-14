import 'package:datride_mobile/core/maps/map_screen.dart';
// import 'package:datride_mobile/screens/book_ride/book_ride.dart';
import 'package:datride_mobile/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation = AlwaysStoppedAnimation(
    0.0,
  ); // Default initialization
  late Animation<Offset> _slideAnimation;

  // Sample data for charts
  final List<double> weeklyTrips = [3, 5, 2, 6, 4, 7, 2];
  final List<double> monthlySpending = [48, 70, 36, 80, 52, 95, 35];

  @override
  void initState() {
    super.initState();

    // Set status bar color to match app theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context); // Added this line

    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDarkMode), // Pass isDarkMode to header
              SizedBox(height: 20),
              _buildWalletCard(isDarkMode), // Pass isDarkMode to wallet card
              SizedBox(height: 20),
              _buildQuickActions(
                isDarkMode,
              ), // Pass isDarkMode to quick actions
              SizedBox(height: 30),
              _buildAnalyticsSection(
                isDarkMode,
              ), // Pass isDarkMode to analytics
              SizedBox(height: 20),
              _buildSpecialEligibility(
                isDarkMode,
              ), // Pass isDarkMode to special eligibility
              SizedBox(height: 30),
              _buildRecentActivity(
                isDarkMode,
              ), // Pass isDarkMode to recent activity
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: TextStyle(
                  color:
                      isDarkMode
                          ? Colors.grey.shade400
                          : Colors.black54, // Updated color
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Alex Johnson',
                style: TextStyle(
                  color:
                      isDarkMode ? Colors.white : Colors.black, // Updated color
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade300, // Updated color
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDarkMode ? Colors.white : Colors.black,
              ), // Updated color
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Notifications tapped')));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Wallet details tapped')));
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  isDarkMode
                      ? LinearGradient(
                        colors: [Colors.purple, Colors.deepPurple.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null, // No gradient in light mode
              color:
                  isDarkMode
                      ? null
                      : Colors.white, // White background in light mode
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (isDarkMode)
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DATRIDE WALLET',
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black54, // Updated color
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black54, // Updated color
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  '\$149.50',
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white
                            : Colors.black, // Updated color
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Available Balance',
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : Colors.black54, // Updated color
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Add Money tapped')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDarkMode
                                ? Colors.white
                                : Colors.purple, // Updated color
                        foregroundColor:
                            isDarkMode
                                ? Colors.purple
                                : Colors.white, // Updated color
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('ADD MONEY'),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('History tapped')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            isDarkMode
                                ? Colors.white
                                : Colors.purple, // Updated color
                        side: BorderSide(
                          color: isDarkMode ? Colors.white70 : Colors.purple,
                        ), // Updated color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('HISTORY'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Activity',
              style: TextStyle(
                color:
                    isDarkMode ? Colors.white : Colors.black, // Updated color
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Trips',
                    value: '27',
                    icon: Icons.directions_car,
                    color: Colors.blue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Total trips tapped')),
                      );
                    },
                    isDarkMode: isDarkMode, // Pass isDarkMode
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: 'Distance',
                    value: '342 km',
                    icon: Icons.route,
                    color: Colors.amber,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Distance stats tapped')),
                      );
                    },
                    isDarkMode: isDarkMode, // Pass isDarkMode
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Spent',
                    value: '\$389',
                    icon: Icons.attach_money,
                    color: Colors.green,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Spending stats tapped')),
                      );
                    },
                    isDarkMode: isDarkMode, // Pass isDarkMode
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    title: 'Saved Time',
                    value: '18 hrs',
                    icon: Icons.timer,
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Time saved stats tapped')),
                      );
                    },
                    isDarkMode: isDarkMode, // Pass isDarkMode
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade300, // Updated color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weekly Trips',
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : Colors.black, // Updated color
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Weekly stats details tapped'),
                            ),
                          );
                        },
                        child: Text(
                          'See Details',
                          style: TextStyle(color: Colors.purple, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 180,
                    padding: EdgeInsets.only(top: 15),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final style = TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.black54, // Updated color
                                  fontSize: 12,
                                );
                                String text;
                                switch (value.toInt()) {
                                  case 0:
                                    text = 'M';
                                    break;
                                  case 1:
                                    text = 'T';
                                    break;
                                  case 2:
                                    text = 'W';
                                    break;
                                  case 3:
                                    text = 'T';
                                    break;
                                  case 4:
                                    text = 'F';
                                    break;
                                  case 5:
                                    text = 'S';
                                    break;
                                  case 6:
                                    text = 'S';
                                    break;
                                  default:
                                    text = '';
                                }
                                return Text(text, style: style);
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        barGroups:
                            weeklyTrips.asMap().entries.map((entry) {
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    fromY: 0,
                                    toY: entry.value,
                                    color: Colors.purple,
                                    width: 15,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Function onTap,
    required bool isDarkMode, // Added isDarkMode
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade300, // Updated color
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color:
                    isDarkMode ? Colors.white : Colors.black, // Updated color
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color:
                    isDarkMode
                        ? Colors.grey.shade400
                        : Colors.black54, // Updated color
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDarkMode) {
    final List<Map<String, dynamic>> actions = [
      {
        'title': 'Book a Ride',
        'icon': Icons.local_taxi,
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        },
      },
      {
        'title': 'Reserve',
        'icon': Icons.calendar_today,
        'color': Colors.orange,
        'onTap': () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Reserve tapped')));
        },
      },
      {
        'title': 'Packages',
        'icon': Icons.card_giftcard,
        'color': Colors.green,
        'onTap': () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Packages tapped')));
        },
      },
      {
        'title': 'Support',
        'icon': Icons.headset_mic,
        'color': Colors.red,
        'onTap': () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Support tapped')));
        },
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                color:
                    isDarkMode ? Colors.white : Colors.black, // Updated color
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  actions.map((action) {
                    return GestureDetector(
                      onTap: action['onTap'],
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: action['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              action['icon'],
                              color: action['color'],
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            action['title'],
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : Colors.black, // Updated color
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialEligibility(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Special eligibility tapped')),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade700, Colors.orange.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, color: Colors.white, size: 30),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIP Silver Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'You\'re eligible for 10% off weekend rides',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isDarkMode) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Downtown Trip',
        'date': 'Today, 2:30 PM',
        'amount': '\$24.50',
        'icon': Icons.location_on,
        'iconColor': Colors.blue,
      },
      {
        'title': 'Added to Wallet',
        'date': 'Yesterday, 6:15 PM',
        'amount': '+\$50.00',
        'icon': Icons.account_balance_wallet,
        'iconColor': Colors.green,
      },
      {
        'title': 'Airport Ride',
        'date': 'Mar 20, 9:45 AM',
        'amount': '\$35.75',
        'icon': Icons.flight,
        'iconColor': Colors.purple,
      },
    ];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.white
                            : Colors.black, // Updated color
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('View all activities tapped')),
                    );
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(color: Colors.purple, fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            ...activities.map((activity) {
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${activity['title']} tapped')),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.shade300, // Updated color
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: activity['iconColor'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          activity['icon'],
                          color: activity['iconColor'],
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title'],
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white
                                        : Colors.black, // Updated color
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              activity['date'],
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.black54, // Updated color
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        activity['amount'],
                        style: TextStyle(
                          color:
                              activity['amount'].contains('+')
                                  ? Colors.green
                                  : isDarkMode
                                  ? Colors.white
                                  : Colors.black, // Updated color
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
