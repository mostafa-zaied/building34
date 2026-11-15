import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import 'feedback_screen.dart';
import 'home_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuildingCubit, BuildingState>(
      listenWhen: (prev, curr) => prev.feedbackMessage != curr.feedbackMessage && curr.feedbackMessage != null,
      listener: (context, state) {
        if (state.feedbackMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.feedbackMessage!),
              backgroundColor: state.feedbackIsError ? Colors.redAccent : const Color(0xFF22C55E),
            ),
          );
          context.read<BuildingCubit>().clearFeedback();
        }
      },
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;

        const screens = [
          BuildingHomePage(),
          FeedbackScreen(type: 'complaint'),
          FeedbackScreen(type: 'improvement'),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            if (isWide) {
              return Scaffold(
                body: SafeArea(
                  child: Row(
                    children: [
                      NavigationRail(
                        selectedIndex: state.selectedNavIndex,
                        onDestinationSelected: cubit.selectNav,
                        extended: constraints.maxWidth >= 980,
                        backgroundColor: Theme.of(context).cardColor,
                        indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🏢', style: TextStyle(fontSize: 22)),
                              if (constraints.maxWidth >= 980) ...[
                                const SizedBox(width: 8),
                                Text(
                                  s.appTitle,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ),
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.receipt_long_outlined),
                            selectedIcon: const Icon(Icons.receipt_long_rounded),
                            label: Text(s.navExpenses),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.campaign_outlined),
                            selectedIcon: const Icon(Icons.campaign_rounded),
                            label: Text(s.navComplaints),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.lightbulb_outline),
                            selectedIcon: const Icon(Icons.lightbulb_rounded),
                            label: Text(s.navImprovements),
                          ),
                        ],
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: state.selectedNavIndex,
                          children: screens,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              body: SafeArea(
                child: IndexedStack(
                  index: state.selectedNavIndex,
                  children: screens,
                ),
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: state.selectedNavIndex,
                onDestinationSelected: cubit.selectNav,
                backgroundColor: Theme.of(context).cardColor,
                indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.2),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.receipt_long_outlined),
                    selectedIcon: const Icon(Icons.receipt_long_rounded),
                    label: s.navExpenses,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.campaign_outlined),
                    selectedIcon: const Icon(Icons.campaign_rounded),
                    label: s.navComplaints,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.lightbulb_outline),
                    selectedIcon: const Icon(Icons.lightbulb_rounded),
                    label: s.navImprovements,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
