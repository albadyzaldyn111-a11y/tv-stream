import 'dart:async';

import 'package:flutter/material.dart';

import '../models/channel.dart';
import '../services/channel_api.dart';
import '../services/favorites_store.dart';
import '../widgets/channel_card.dart';
import 'channel_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ChannelApi();
  final _favoritesStore = FavoritesStore();
  final _searchController = TextEditingController();

  List<Channel> _channels = const [];
  List<String> _categories = const [];
  Set<int> _favoriteIds = <int>{};
  String _selectedCategory = 'all';
  String? _error;
  bool _loading = true;
  bool _showFavorites = false;
  Timer? _searchDebounce;

  List<Channel> get _visibleChannels => _showFavorites
      ? _channels
          .where((channel) => _favoriteIds.contains(channel.id))
          .toList(growable: false)
      : _channels;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.fetchChannels(),
        _api.fetchCategories(),
        _favoritesStore.load(),
      ]);
      if (!mounted) return;
      setState(() {
        _channels = results[0] as List<Channel>;
        _categories = results[1] as List<String>;
        _favoriteIds = results[2] as Set<int>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'تعذر الاتصال بالخادم. تأكد من تشغيل الـBackend ثم حاول مرة أخرى.';
      });
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce =
        Timer(const Duration(milliseconds: 350), _refreshChannels);
  }

  Future<void> _refreshChannels() async {
    try {
      final channels = await _api.fetchChannels(
        category: _selectedCategory,
        query: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _channels = channels;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'تعذر تحديث النتائج.');
    }
  }

  Future<void> _selectCategory(String category) async {
    setState(() => _selectedCategory = category);
    await _refreshChannels();
  }

  Future<void> _toggleFavorite(Channel channel) async {
    final ids = await _favoritesStore.toggle(channel.id);
    if (mounted) setState(() => _favoriteIds = ids);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TV STREAM',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildIntro()),
            SliverToBoxAdapter(child: _buildCategories()),
            if (_loading)
              const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              SliverFillRemaining(hasScrollBody: false, child: _buildError())
            else if (_visibleChannels.isEmpty)
              SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: Text(_showFavorites
                          ? 'لم تضف قنوات إلى المفضلة بعد.'
                          : 'لا توجد قنوات مطابقة.')))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 1050
                        ? 4
                        : width >= 700
                            ? 3
                            : 2;
                    return SliverGrid.builder(
                      itemCount: _visibleChannels.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: .78,
                      ),
                      itemBuilder: (_, index) {
                        final channel = _visibleChannels[index];
                        return ChannelCard(
                          channel: channel,
                          isFavorite: _favoriteIds.contains(channel.id),
                          onFavorite: () => _toggleFavorite(channel),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    ChannelDetailsPage(channel: channel)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _showFavorites ? 1 : 0,
        onDestinationSelected: (index) =>
            setState(() => _showFavorites = index == 1),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.star_border),
              selectedIcon: Icon(Icons.star),
              label: 'المفضلة'),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('شاهد مصادرك الرسمية',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('قنوات عربية في مكان واحد، مع احترام حقوق أصحاب المحتوى.',
              style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'ابحث عن قناة أو دولة',
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['all', ..._categories];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final category = categories[index];
          return ChoiceChip(
            label: Text(_categoryLabel(category)),
            selected: _selectedCategory == category,
            onSelected: (_) => _selectCategory(category),
          );
        },
      ),
    );
  }

  String _categoryLabel(String value) {
    const labels = {
      'all': 'الكل',
      'Kids': 'أطفال',
      'News': 'أخبار',
      'General': 'عامة',
      'Sports': 'رياضة',
      'Entertainment': 'ترفيه',
      'Religious': 'دينية',
      'Educational': 'تعليمية',
      'Culture': 'ثقافية',
      'International': 'دولية',
    };
    return labels[value] ?? value;
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.white54),
          const SizedBox(height: 14),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
