import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import 'tabs/recent_tab.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/search_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _navAnimationController;
  late final AnimationController _fabAnimationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      _navAnimationController
        ..reset()
        ..forward();

      if (index == 0) {
        context.read<HomeBloc>().add(const LoadRecentRecipes());
      } else if (index == 1) {
        context.read<HomeBloc>().add(const LoadFavoriteRecipes());
      }
    }
  }

  void _onPageChanged(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.read<HomeBloc>().add(const LoadRecentRecipes());
      if (index == 1) {
        context.read<HomeBloc>().add(const LoadFavoriteRecipes());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        extendBody: true,
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: const [
            RecentTab(),
            FavoritesTab(),
            SearchTab(),
          ],
        ),
        bottomNavigationBar: _buildNavBar(),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFloatingActionButton(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildNavBar() {
    return AnimatedBuilder(
      animation: _navAnimationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.deepOrange)
                    .withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color(0xFF2D1B15),
                      const Color(0xFF1A1008),
                    ]
                  : [
                      const Color(0xFFFFF8F3),
                      const Color(0xFFFFF0E6),
                    ],
            ),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.deepOrange.withValues(alpha: 0.2)
                  : Colors.deepOrange.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.deepOrange.shade700,
              unselectedItemColor: Colors.deepOrange.withValues(alpha: 0.5),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: _AnimatedNavIcon(
                    icon: Icons.history_rounded,
                    selectedIcon: Icons.history_rounded,
                    isSelected: _currentIndex == 0,
                    animation: _navAnimationController,
                    index: 0,
                  ),
                  label: 'Recientes',
                ),
                BottomNavigationBarItem(
                  icon: _AnimatedNavIcon(
                    icon: Icons.favorite_border_rounded,
                    selectedIcon: Icons.favorite_rounded,
                    isSelected: _currentIndex == 1,
                    animation: _navAnimationController,
                    index: 1,
                  ),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: _AnimatedNavIcon(
                    icon: Icons.search_rounded,
                    selectedIcon: Icons.search_rounded,
                    isSelected: _currentIndex == 2,
                    animation: _navAnimationController,
                    index: 2,
                  ),
                  label: 'Buscar',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimationController.value,
          child: FloatingActionButton.extended(
            onPressed: () => context.push('/search'),
            backgroundColor: Colors.deepOrange.shade700,
            foregroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            icon: const Icon(Icons.search_rounded, size: 22),
            label: const Text(
              'Buscar recetas',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final AnimationController animation;
  final int index;

  const _AnimatedNavIcon({
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.animation,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Colors.deepOrange.shade700
        : Colors.deepOrange.withValues(alpha: 0.5);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = isSelected
            ? Curves.elasticOut.transform(animation.value)
            : 1.0 - Curves.elasticOut.transform(animation.value);

        return Transform.scale(
          scale: 0.85 + 0.15 * progress,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween(begin: -0.125, end: 0.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              key: ValueKey(isSelected),
              color: color,
              size: 26,
            ),
          ),
        );
      },
    );
  }
}