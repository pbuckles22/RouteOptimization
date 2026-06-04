import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:route_optimization/models/app_state.dart';
import 'package:route_optimization/providers/route_provider.dart';

class RouteDashboard extends StatefulWidget {
  const RouteDashboard({super.key});

  @override
  State<RouteDashboard> createState() => _RouteDashboardState();
}

class _RouteDashboardState extends State<RouteDashboard> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteProvider>().ensureSearchProximity();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteWise'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final left = _StopsPanel(searchController: _searchController);
          final right = const _ActionsPanel();

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: left),
                const VerticalDivider(width: 1),
                Expanded(flex: 2, child: right),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: left),
              const Divider(height: 1),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }
}

class _StopsPanel extends StatelessWidget {
  const _StopsPanel({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search places',
                  hintText: 'Address or business (e.g. 2314 Johnson Ave, McDonald\'s)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: provider.onSearchQueryChanged,
              ),
              if (provider.currentState == AppState.searching)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
              if (provider.searchResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Material(
                  elevation: 2,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: provider.searchResults.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = provider.searchResults[index];
                      return ListTile(
                        title: Text(result.name),
                        subtitle: Text(result.formattedAddress),
                        onTap: () async {
                          await provider.selectSearchResult(result);
                          searchController.clear();
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Your stops',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: provider.activeStops.isEmpty
                    ? const Center(
                        child: Text('Add a start location, then more stops.'),
                      )
                    : ListView.builder(
                        itemCount: provider.activeStops.length,
                        itemBuilder: (context, index) {
                          final stop = provider.activeStops[index];
                          final isStart = provider.isOrigin(index);
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(stop.name),
                            subtitle: Text(stop.formattedAddress),
                            trailing: isStart
                                ? const Chip(label: Text('Start'))
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () =>
                                        provider.removeStopAt(index),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionsPanel extends StatelessWidget {
  const _ActionsPanel();

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, provider, _) {
        final optimizing = provider.currentState == AppState.optimizing;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Route',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (provider.errorMessage != null)
                Text(
                  provider.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              if (provider.totalDistanceMiles != null)
                Text(
                  'Estimated distance: '
                  '${provider.totalDistanceMiles!.toStringAsFixed(1)} mi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 16),
              if (provider.activeStops.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.activeStops.length,
                    itemBuilder: (context, index) {
                      final stop = provider.activeStops[index];
                      return ListTile(
                        leading: Text('${index + 1}.'),
                        title: Text(stop.name),
                        subtitle: Text(stop.formattedAddress),
                      );
                    },
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Add at least two stops, then optimize for the best order.',
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: provider.canOptimize && !optimizing
                    ? provider.optimize
                    : null,
                icon: optimizing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.route),
                label: Text(optimizing ? 'Optimizing…' : 'Optimize route'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: provider.canLaunchMaps
                    ? provider.launchGoogleMaps
                    : null,
                icon: const Icon(Icons.map),
                label: const Text('Launch in Google Maps'),
              ),
            ],
          ),
        );
      },
    );
  }
}
