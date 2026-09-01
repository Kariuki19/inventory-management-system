import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/consultation_utils.dart';
import '../../auth/screens/widget_tree.dart';
import '../../demo/screens/demo_workspace_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Interactive state
  final bool _isExpanded = false;
  int _selectedFeature = -1;
  int _selectedGuideStep = -1;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();

  // Theme-aware color palette for feature icons
  static Map<IconData, Color> getFeatureIconColors(
      bool isDarkMode, Color primaryColor) {
    if (isDarkMode) {
      // Dark mode: Brighter, more saturated colors for better visibility
      return {
        Icons.timeline: const Color(0xFF42A5F5), // Bright blue
        Icons.sync_alt: const Color(0xFF66BB6A), // Bright green
        Icons.auto_graph: const Color(0xFFFFB74D), // Bright orange
        Icons.people_alt_outlined: const Color(0xFFBA68C8), // Bright purple
        Icons.inventory_2: const Color(0xFF42A5F5), // Bright blue
        Icons.inventory: const Color(0xFF42A5F5), // Bright blue
        Icons.bar_chart: const Color(0xFF42A5F5), // Bright blue
        Icons.notifications: const Color(0xFFFFB74D), // Bright orange
        Icons.security: const Color(0xFFBA68C8), // Bright purple
        Icons.login: const Color(0xFF42A5F5), // Bright blue
        Icons.analytics: const Color(0xFF42A5F5), // Bright blue
        Icons.group_add: const Color(0xFF42A5F5), // Bright blue
        Icons.trending_up: const Color(0xFF66BB6A), // Bright green
        Icons.speed: const Color(0xFFFFB74D), // Bright orange
        Icons.group: const Color(0xFFBA68C8), // Bright purple
      };
    } else {
      // Light mode: Professional colors with good contrast
      return {
        Icons.timeline: const Color(0xFF1976D2), // Professional blue
        Icons.sync_alt: const Color(0xFF388E3C), // Professional green
        Icons.auto_graph: const Color(0xFFF57C00), // Professional orange
        Icons.people_alt_outlined:
            const Color(0xFF7B1FA2), // Professional purple
        Icons.inventory_2: const Color(0xFF1976D2), // Professional blue
        Icons.inventory: const Color(0xFF1976D2), // Professional blue
        Icons.bar_chart: const Color(0xFF1976D2), // Professional blue
        Icons.notifications: const Color(0xFFF57C00), // Professional orange
        Icons.security: const Color(0xFF7B1FA2), // Professional purple
        Icons.login: const Color(0xFF1976D2), // Professional blue
        Icons.analytics: const Color(0xFF1976D2), // Professional blue
        Icons.group_add: const Color(0xFF1976D2), // Professional blue
        Icons.trending_up: const Color(0xFF388E3C), // Professional green
        Icons.speed: const Color(0xFFF57C00), // Professional orange
        Icons.group: const Color(0xFF7B1FA2), // Professional purple
      };
    }
  }


  @override
  void initState() {
    super.initState();

    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Start animations with delays for smooth, professional loading
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(
    kToolbarHeight,
  ),
  child: ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Your existing AppBar
          AppBar(
            backgroundColor: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'StockSense',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            actions: [
              if (!isSmallScreen) ...[
                _buildNavLink(
                    'Features', isDarkMode, () => _scrollToSection(_featuresKey)),
                _buildNavLink(
                    'Pricing', isDarkMode, () => _scrollToSection(_pricingKey)),
                _buildNavLink(
                    'About', isDarkMode, () => _scrollToSection(_aboutKey)),
              ],

            ],
          ),
          
        ],
      ),
    ),
  ),
),
      
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          const Color(0xFF121212),
                          const Color(0xFF1e1e1e),
                          const Color(0xFF0f0f0f),
                        ]
                      : [
                          Colors.grey[50]!,
                          Colors.grey[25] ?? Colors.white,
                          Colors.white,
                          Colors.white,
                        ],
                  stops: isDarkMode
                      ? const [0.0, 0.5, 1.0]
                      : const [0.0, 0.33, 0.67, 1.0],
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          // Hero Section with Background
                          AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: _buildHeroSection(context, isDarkMode,
                                    isSmallScreen, isMediumScreen),
                              );
                            },
                          ),

                          Padding(
                            key: _featuresKey,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 80),
                                // App Overview Section
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 900),
                                    child: _buildAppOverview(context, isDarkMode,
                                        isSmallScreen, isMediumScreen),
                                  ),
                                ),

                                const SizedBox(height: 80),

                                // Interactive Features Section
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 900),
                                    child: _buildFeaturesSection(context, isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            key: _pricingKey,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 80),

                                // Pricing Section
                                _buildPricingSection(
                                    context, isDarkMode, isSmallScreen, isMediumScreen),
                              ],
                            ),
                          ),

                          Padding(
                            key: _aboutKey,
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 80),

                                // Consultation Section
                                Center(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        ConsultationUtils.showConsultationDialog(context),
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      'Book a Consultation',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFFFF6B00),
                                      side: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white54
                                              : const Color(0xFFFF6B00)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 80),

                                // Quick Start Guide
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 900),
                                    child: _buildQuickGuideSection(context, isDarkMode),
                                  ),
                                ),

                                const SizedBox(height: 80),

                                // Stats Section
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 900),
                                    child: _buildStatsSection(context, isDarkMode),
                                  ),
                                ),

                                const SizedBox(height: 80),
                              ],
                            ),
                          ),

                          // Footer Section
                          _buildFooter(context, isDarkMode),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildNavLink(String title, bool isDarkMode, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDarkMode,
      bool isSmallScreen, bool isMediumScreen) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/landing_image.png'),
          fit: BoxFit.cover,
          opacity: 0.25,
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 80, 24, 60),
      child: Column(
      children: [
        // Animated Logo with Glow Effect
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withValues(alpha: 0.3),
                theme.primaryColor.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 25,
                spreadRadius: 8,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/orange_logo.jpeg',
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // App Title with Gradient Text
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDarkMode
                ? [Colors.white, Colors.white70]
                : [Colors.black87, Colors.black],
          ).createShader(bounds),
          child: Text(
            'StockSense',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontFamilyFallback: ['Roboto', 'sans-serif'],
              fontSize: isSmallScreen ? 32 : (isMediumScreen ? 36 : 42),
              fontWeight: FontWeight.bold,
              color: Colors.white, // Required for ShaderMask
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle
        Text(
          'Smart Inventory Management,\nSimplified.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontFamilyFallback: ['Roboto', 'sans-serif'],
            fontSize: isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
            fontWeight: FontWeight.w400,
            color: isDarkMode ? Colors.white70 : Colors.black87,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),

        // Tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            'AI-Powered • Real-Time • Secure',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontFamilyFallback: ['Roboto', 'sans-serif'],
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Demo Button
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF8C00), // Dark Orange
                Color(0xFFFF6B00), // Cloudora Orange
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B00).withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DemoWorkspaceScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Explore Interactive Demo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        _buildGetStartedButton(context),
      ],
    ),
  );
}

  Widget _buildAppOverview(BuildContext context, bool isDarkMode,
      bool isSmallScreen, bool isMediumScreen) {
    final theme = Theme.of(context);

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'What is StockSense?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontFamilyFallback: ['Roboto', 'sans-serif'],
                fontSize: isSmallScreen ? 20 : (isMediumScreen ? 22 : 24),
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[200]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 32,
                    color: isDarkMode ? Colors.amber[400] : theme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'StockSense is a comprehensive inventory management solution designed for modern businesses. Using advanced AI algorithms and real-time analytics, it helps you maintain optimal stock levels, predict future needs, and streamline your operations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontFamilyFallback: ['Roboto', 'sans-serif'],
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      height: 1.6,
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

  Widget _buildPricingSection(BuildContext context, bool isDarkMode,
      bool isSmallScreen, bool isMediumScreen) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => ScaleAnimation(
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'Simple Pricing',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose the plan that fits your business',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDarkMode ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            if (isSmallScreen) ...[
              _PricingCard(
                title: 'Basic',
                price: 'KES 5,200',
                usdPrice: '\$40',
                description: 'Small shops & boutiques',
                pricingOptions: const [
                  {'kes': 'KES 3,900', 'usd': '\$30'},
                  {'kes': 'KES 5,200', 'usd': '\$40'},
                ],
                isDarkMode: isDarkMode,
                isHighlight: false,
                onSelectPlan: () => ConsultationUtils.showConsultationDialog(context, plan: 'Basic'),
              ),
              const SizedBox(height: 16),
              _PricingCard(
                title: 'Pro',
                price: 'KES 13,000',
                usdPrice: '\$100',
                description: 'Growing SMEs',
                pricingOptions: const [
                  {'kes': 'KES 10,400', 'usd': '\$80'},
                  {'kes': 'KES 11,700', 'usd': '\$90'},
                  {'kes': 'KES 13,000', 'usd': '\$100'},
                ],
                isDarkMode: isDarkMode,
                isHighlight: true,
                onSelectPlan: () => ConsultationUtils.showConsultationDialog(context, plan: 'Pro'),
              ),
              const SizedBox(height: 16),
              _PricingCard(
                title: 'Premium',
                price: 'KES 48,750',
                usdPrice: '\$375',
                description: 'Retail chains',
                pricingOptions: const [
                  {'kes': 'KES 42,900', 'usd': '\$330'},
                  {'kes': 'KES 45,500', 'usd': '\$350'},
                  {'kes': 'KES 48,750', 'usd': '\$375'},
                ],
                isDarkMode: isDarkMode,
                isHighlight: false,
                onSelectPlan: () => ConsultationUtils.showConsultationDialog(context, plan: 'Premium'),
              ),
            ] else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PricingCard(
                      title: 'Basic',
                      price: 'KES 5,200',
                      usdPrice: '\$40',
                      description: 'Small shops & boutiques',
                      pricingOptions: const [
                        {'kes': 'KES 3,900', 'usd': '\$30'},
                        {'kes': 'KES 5,200', 'usd': '\$40'},
                      ],
                      isDarkMode: isDarkMode,
                      isHighlight: false,
                      onSelectPlan: () => ConsultationUtils.showConsultationDialog(context, plan: 'Basic'),
                    ),
                    const SizedBox(width: 16),
                    _PricingCard(
                      title: 'Pro',
                      price: 'KES 13,000',
                      usdPrice: '\$100',
                      description: 'Growing SMEs',
                      pricingOptions: const [
                        {'kes': 'KES 10,400', 'usd': '\$80'},
                        {'kes': 'KES 11,700', 'usd': '\$90'},
                        {'kes': 'KES 13,000', 'usd': '\$100'},
                      ],
                      isDarkMode: isDarkMode,
                      isHighlight: true,
                      onSelectPlan: () => ConsultationUtils.showConsultationDialog(context, plan: 'Pro'),
                    ),
                    const SizedBox(width: 16),
                    _PricingCard(
                      title: 'Premium',
                      price: 'KES 48,750',
                      usdPrice: '\$375',
                      description: 'Retail chains',
                      pricingOptions: const [
                        {'kes': 'KES 42,900', 'usd': '\$330'},
                        {'kes': 'KES 45,500', 'usd': '\$350'},
                        {'kes': 'KES 48,750', 'usd': '\$375'},
                      ],
                      isDarkMode: isDarkMode,
                      isHighlight: false,
                      onSelectPlan: () => ConsultationUtils.showConsultationDialog(context, plan: 'Premium'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Text(
                  'One-time deployment fee equal to 20% of the monthly plan applies for setup and onboarding',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
            _buildFeatureTable(context, isDarkMode, isSmallScreen, isMediumScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTable(BuildContext context, bool isDarkMode,
      bool isSmallScreen, bool isMediumScreen) {
    return Column(
      children: [
        Text(
          'Compare Features',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[200]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 900),
                    child: DataTable(
                      horizontalMargin: 24,
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFFF6B00),
                      ),
                      dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                        (Set<WidgetState> states) => Colors.transparent,
                      ),
                      columns: [
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text('Features',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text('Basic',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text('Pro',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text('Premium',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        _buildDataRow('Staff/User Capacity', '5 - 10', '10 - 25', '50 - Unlimited', isDarkMode, isEven: false),
                        _buildDataRow('Inventory', 'Basic', 'Advanced', 'Multi-location', isDarkMode, isEven: true),
                        _buildDataRow('Support', 'Email', 'Priority', 'Dedicated', isDarkMode, isEven: false),
                        _buildDataRow('Advanced Analytics', '—', 'Included', 'Included', isDarkMode, isEven: true),
                        _buildDataRow('AI Predictions', '—', 'Included', 'Included', isDarkMode, isEven: false),
                        _buildDataRow('Custom Integrations', '—', '—', 'Included', isDarkMode, isEven: true),
                        _buildDataRow(
                            'Messaging Allowance',
                            'Standard (+33) for \$2',
                            'Business (+50) for \$3',
                            'Enterprise (+100) for \$6',
                            isDarkMode, isEven: false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(String feature, String entry, String mid, String premium,
      bool isDarkMode, {bool isEven = false}) {
    final rowColor = isEven 
        ? (isDarkMode ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F5F5))
        : Colors.transparent;

    return DataRow(
      color: WidgetStateProperty.all(rowColor),
      cells: [
        DataCell(Center(
          child: Text(feature,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87)),
        )),
        DataCell(Center(
          child: Text(entry,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white60 : Colors.black54)),
        )),
        DataCell(Center(
          child: Text(mid,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white60 : Colors.black54)),
        )),
        DataCell(Center(
          child: Text(premium,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white60 : Colors.black54)),
        )),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'Powerful Features',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontFamilyFallback: ['Roboto', 'sans-serif'],
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            _buildInteractiveFeature(
              context,
              icon: Icons.timeline,
              title: 'Real-time Tracking',
              subtitle: 'Monitor your inventory levels and values instantly.',
              details:
                  'Get live updates on stock levels, values, and movements across all your locations.',
              isDarkMode: isDarkMode,
            ),
            _buildInteractiveFeature(
              context,
              icon: Icons.sync_alt,
              title: 'Stock Movements',
              subtitle:
                  'Log every stock addition, removal, or transfer with ease.',
              details:
                  'Track all inventory changes with detailed audit trails and automated logging.',
              isDarkMode: isDarkMode,
            ),
            _buildInteractiveFeature(
              context,
              icon: Icons.auto_graph,
              title: 'AI-Powered Predictions',
              subtitle: 'Forecast future stock needs to prevent shortages.',
              details:
                  'Machine learning algorithms predict demand patterns and alert you before stock runs out.',
              isDarkMode: isDarkMode,
            ),
            _buildInteractiveFeature(
              context,
              icon: Icons.people_alt_outlined,
              title: 'User Role Management',
              subtitle: 'Assign roles and permissions for secure team access.',
              details:
                  'Multi-user support with customizable permissions and secure access controls.',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFeature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String details,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);
    final iconColor =
        getFeatureIconColors(isDarkMode, theme.primaryColor)[icon] ??
            theme.primaryColor;
    final isSelected = _selectedFeature == icon.hashCode;

    return AnimationLimiter(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFeature = isSelected ? -1 : icon.hashCode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? iconColor.withValues(alpha: 0.1)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? iconColor.withValues(alpha: 0.3)
                  : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[200]!),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          iconColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: isSelected ? 28 : 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white60 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: isSelected ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDarkMode ? Colors.white60 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isSelected ? null : 0,
                child: isSelected
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Divider(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey[300],
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            details,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickGuideSection(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'Quick Start Guide',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get up and running in minutes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: isDarkMode ? Colors.white60 : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildGuideStep(
              context,
              step: 1,
              icon: Icons.login,
              title: 'Get Started',
              description:
                  'Contact us to schedule a demo and get started with StockSense.',
              isDarkMode: isDarkMode,
            ),
            _buildGuideStep(
              context,
              step: 2,
              icon: Icons.inventory,
              title: 'Add Your First Item',
              description:
                  'Start by adding your inventory items with details and categories.',
              isDarkMode: isDarkMode,
            ),
            _buildGuideStep(
              context,
              step: 3,
              icon: Icons.analytics,
              title: 'Monitor & Predict',
              description:
                  'Let AI analyze your patterns and provide smart predictions.',
              isDarkMode: isDarkMode,
            ),
            _buildGuideStep(
              context,
              step: 4,
              icon: Icons.group_add,
              title: 'Invite Your Team',
              description:
                  'Add team members and assign appropriate roles and permissions.',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(
    BuildContext context, {
    required int step,
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    final theme = Theme.of(context);
    final iconColor =
        getFeatureIconColors(isDarkMode, theme.primaryColor)[icon] ??
            theme.primaryColor;
    final isSelected = _selectedGuideStep == step;

    return AnimationLimiter(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGuideStep = isSelected ? -1 : step;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? iconColor.withValues(alpha: 0.1)
                : (isDarkMode
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? iconColor.withValues(alpha: 0.3)
                  : (isDarkMode
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[200]!),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          iconColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: GoogleFonts.poppins(
                          fontSize: isSelected ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        child: Text(step.toString()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white60 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: isSelected ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDarkMode ? Colors.white60 : Colors.grey[400],
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isSelected ? null : 0,
                child: isSelected
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          Divider(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey[300],
                            height: 1,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailedGuideStep(step, isDarkMode),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedGuideStep(int step, bool isDarkMode) {
    final details = _getGuideStepDetails(step);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              'What you\'ll do:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: isDarkMode ? Colors.white60 : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getGuideStepTip(step),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<String> _getGuideStepDetails(int step) {
    switch (step) {
      case 1:
        return [
          'Create a new account with your email and password',
          'Or sign in if you already have an account',
          'Verify your email for security (optional)',
          'Set up your basic profile information'
        ];
      case 2:
        return [
          'Navigate to the inventory section',
          'Tap "Add Item" to create your first product',
          'Fill in item details: name, description, category',
          'Set quantity, price, and reorder levels',
          'Upload product images if available'
        ];
      case 3:
        return [
          'View your dashboard for real-time insights',
          'Check stock predictions and alerts',
          'Monitor inventory value and trends',
          'Review stock movement history',
          'Set up notifications for low stock alerts'
        ];
      case 4:
        return [
          'Go to user management in your profile',
          'Invite team members via email',
          'Assign appropriate roles (Admin/Staff)',
          'Set permissions for different access levels',
          'Manage user accounts and access rights'
        ];
      default:
        return [];
    }
  }

  String _getGuideStepTip(int step) {
    switch (step) {
      case 1:
        return 'Pro tip: Use a strong password and enable two-factor authentication for better security.';
      case 2:
        return 'Pro tip: Start with your most important or fast-moving items to see immediate benefits.';
      case 3:
        return 'Pro tip: Set up email notifications for critical stock alerts to stay on top of inventory.';
      case 4:
        return 'Pro tip: Assign Admin roles sparingly and Staff roles for daily operations.';
      default:
        return '';
    }
  }

  Widget _buildStatsSection(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => ScaleAnimation(
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Text(
              'Why Choose StockSense?',
              style: GoogleFonts.poppins(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.trending_up,
                    value: '99.9%',
                    label: 'Uptime',
                    color: Colors.transparent, // Not used anymore
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.security,
                    value: '256-bit',
                    label: 'Encryption',
                    color: Colors.transparent, // Not used anymore
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.speed,
                    value: '< 1s',
                    label: 'Response Time',
                    color: Colors.transparent, // Not used anymore
                    isDarkMode: isDarkMode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.group,
                    value: 'Team',
                    label: 'Access',
                    color: Colors.transparent, // Not used anymore
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    // Get theme-aware color for the stat icon
    final theme = Theme.of(context);
    final statIconColor =
        getStatIconColor(icon, isDarkMode, theme.primaryColor);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: statIconColor,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Get theme-aware colors for stat icons
  static Color getStatIconColor(
      IconData icon, bool isDarkMode, Color primaryColor) {
    if (isDarkMode) {
      // Dark mode: Bright, vibrant colors for visibility
      switch (icon) {
        case Icons.trending_up:
          return const Color(0xFF66BB6A); // Bright green
        case Icons.security:
          return const Color(0xFF42A5F5); // Bright blue
        case Icons.speed:
          return const Color(0xFFFFB74D); // Bright orange
        case Icons.group:
          return const Color(0xFFBA68C8); // Bright purple
        default:
          return primaryColor;
      }
    } else {
      // Light mode: Professional colors with good contrast
      switch (icon) {
        case Icons.trending_up:
          return const Color(0xFF388E3C); // Professional green
        case Icons.security:
          return const Color(0xFF1976D2); // Professional blue
        case Icons.speed:
          return const Color(0xFFF57C00); // Professional orange
        case Icons.group:
          return const Color(0xFF7B1FA2); // Professional purple
        default:
          return primaryColor;
      }
    }
  }

  Widget _buildFooter(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    final currentYear = DateTime.now().year;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Wrap(
                spacing: 40,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildFooterInfo(
                    icon: Icons.email_outlined,
                    label: 'Support Email',
                    value: 'support@cloudoraltd.live',
                    isDarkMode: isDarkMode,
                    onTap: () => launchUrl(Uri.parse('mailto:support@cloudoraltd.live')),
                  ),
                  _buildFooterInfo(
                    icon: Icons.phone_outlined,
                    label: 'Phone Support',
                    value: '+254 759 585197',
                    isDarkMode: isDarkMode,
                    onTap: () => launchUrl(Uri.parse('tel:+254759585197')),
                  ),
                  _buildFooterInfo(
                    icon: Icons.location_on_outlined,
                    label: 'Based in',
                    value: 'Nairobi, Kenya',
                    isDarkMode: isDarkMode,
                    onTap: null,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '© $currentYear StockSense.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All rights reserved.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterInfo({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimationLimiter(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            // Get Started Button
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 800),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Center(
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _scrollToSection(_pricingKey);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String usdPrice;
  final String description;
  final List<Map<String, String>> pricingOptions;
  final bool isDarkMode;
  final bool isHighlight;
  final VoidCallback onSelectPlan;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.usdPrice,
    required this.description,
    required this.pricingOptions,
    required this.isDarkMode,
    required this.isHighlight,
    required this.onSelectPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode
            ? (isHighlight
                ? theme.primaryColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05))
            : (isHighlight ? const Color(0xFFF0F4FF) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlight
              ? theme.primaryColor
              : (isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
          width: isHighlight ? 2 : 1,
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isHighlight
                  ? theme.primaryColor
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Text(
            usdPrice,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.white60 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Alternative options:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ...pricingOptions.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        option['kes']!,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        option['usd']!,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? Colors.white
                              : (isHighlight ? theme.primaryColor : Colors.black87),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelectPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: isHighlight
                    ? theme.primaryColor
                    : (isDarkMode ? Colors.white10 : Colors.grey[100]),
                foregroundColor: isHighlight
                    ? Colors.white
                    : (isDarkMode ? Colors.white : Colors.black87),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isHighlight ? 4 : 0,
              ),
              child: Text(
                'Choose Plan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
