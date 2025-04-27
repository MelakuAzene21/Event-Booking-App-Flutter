import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/presentation/widgets/event_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> categories = ['All', 'Music', 'Sports', 'Tech', 'Art', 'General'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: const Text('Discover Events'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories
                            .map((category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                      }
                                    },
                                    selectedColor: Theme.of(context).colorScheme.secondary,
                                    labelStyle: TextStyle(
                                      color: _selectedCategory == category
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No events available')),
                  );
                }
                final filteredEvents = events
                    .where((event) =>
                        event.title
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) &&
                        (_selectedCategory == 'All' ||
                            event.category == _selectedCategory))
                    .toList();
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return EventCard(event: filteredEvents[index])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: index * 100))
                          .slideY(begin: 0.2, end: 0);
                    },
                    childCount: filteredEvents.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) {
                print('Error in eventsProvider: $error');
                return SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load events: $error'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => ref.refresh(eventsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}