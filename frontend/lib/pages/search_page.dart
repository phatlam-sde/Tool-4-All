import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tool4all/api/api_client.dart';
import 'package:tool4all/models/PopularToolCard.dart';
import 'package:tool4all/models/QuickActionCard.dart';
import 'package:tool4all/pages/tools_results_page.dart';
import 'package:tool4all/pages/tool_detail_page.dart';
import 'package:tool4all/pages/tools_preview_card.dart';

/// Search/home page for Tool4All.
///
/// Shows:
/// - Quick Actions from backend
/// - Popular Tools from backend
/// - AI search results when the user types
class search_page extends StatefulWidget {
  const search_page({super.key, required this.api});

  /// Used to call the backend.
  final ApiClient api;

  @override
  State<search_page> createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {
  // ---------------------------------------------------------------------------
  // Search input state
  // ---------------------------------------------------------------------------

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool isSearching = false;
  String searchQuery = '';

  // ---------------------------------------------------------------------------
  // Quick Actions state
  // ---------------------------------------------------------------------------

  List<QuickActionItems> quickActionList = [];
  bool isLoadingQuickActions = true;
  String? quickActionsError;

  // ---------------------------------------------------------------------------
  // Popular Tools state
  // ---------------------------------------------------------------------------

  List<PopularToolcard> popularToolList = [];
  bool isLoadingPopularTools = true;
  String? popularToolsError;

  // ---------------------------------------------------------------------------
  // AI Search state
  // ---------------------------------------------------------------------------

  List<dynamic> aiResults = [];
  bool isLoadingAiResults = false;
  String? aiSearchError;

  /// Used to ignore old search results if the user types a new query.
  int _searchRequestId = 0;

  // ---------------------------------------------------------------------------
  // Icon mapping
  // ---------------------------------------------------------------------------

  /// Converts backend icon keys into Flutter icons.
  static const Map<String, IconData> _iconMap = {
    'chat_bubble': Icons.chat_bubble,
    'folder': Icons.folder,
    'image': Icons.image,
    'task': Icons.task,
    'star': Icons.star,
    'pallete': Icons.palette,
    'movie': Icons.movie,
    'smart_toy': Icons.smart_toy,
    'translate': Icons.translate,
    'spell_check': Icons.spellcheck,
    'description': Icons.description,
    'lightbulb': Icons.lightbulb,
    'code': Icons.code,
    'auto_awesome': Icons.auto_awesome,
    'assignment': Icons.assignment,
    'slideshow': Icons.slideshow,
    'search': Icons.search,
    'badge': Icons.badge,
    'table_chart': Icons.table_chart,
    'subject': Icons.subject,
    'edit_note': Icons.edit_note,
  };

  /// Returns the matching icon, or a help icon if unknown.
  IconData _getIcon(String key) => _iconMap[key] ?? Icons.help;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadQuickActions();
    _loadPopularTools();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Backend calls
  // ---------------------------------------------------------------------------

  /// Loads Quick Action cards from GET /quick-actions.
  Future<void> _loadQuickActions() async {
    setState(() {
      isLoadingQuickActions = true;
      quickActionsError = null;
    });

    try {
      final list = await widget.api.getQuickActions();

      final items = list
          .map((e) => QuickActionItems.fromJson(e as Map<String, dynamic>))
          .where((item) => item.taskId.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        quickActionList = items;
        isLoadingQuickActions = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        quickActionsError = e.toString();
        isLoadingQuickActions = false;
      });
    }
  }

  /// Loads Popular Tools from GET /popularTools.
  Future<void> _loadPopularTools() async {
    setState(() {
      isLoadingPopularTools = true;
      popularToolsError = null;
    });

    try {
      final list = await widget.api.getPopularTools(
        limit: 5,
        minPopularity: 70,
      );

      final items = list
          .map((e) => PopularToolcard.fromJson(e as Map<String, dynamic>))
          .where((tool) => tool.toolId.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        popularToolList = items;
        isLoadingPopularTools = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        popularToolsError = e.toString();
        isLoadingPopularTools = false;
      });
    }
  }

  /// Sends the user's query to POST /tools/recommend.
  Future<void> _searchWithAI(String query) async {
    final int currentRequestId = ++_searchRequestId;

    setState(() {
      isLoadingAiResults = true;
      aiSearchError = null;
    });

    try {
      final results = await widget.api.recommendTools(
        query,
        platforms: ['web'],
        limit: 5,
      );

      if (!mounted || currentRequestId != _searchRequestId) return;

      setState(() {
        aiResults = results;
        isLoadingAiResults = false;
      });
    } catch (e) {
      if (!mounted || currentRequestId != _searchRequestId) return;

      setState(() {
        aiSearchError = e.toString();
        isLoadingAiResults = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Search handlers
  // ---------------------------------------------------------------------------

  /// Runs when the user types in the search box.
  void _onSearchChanged(String value) {
    final trimmedValue = value.trim();

    setState(() {
      searchQuery = value;
      isSearching = trimmedValue.isNotEmpty;
    });

    _searchDebounce?.cancel();

    if (trimmedValue.isEmpty) {
      _clearSearchResultsOnly();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 800), () {
      _searchWithAI(trimmedValue);
    });
  }

  /// Clears the search box and returns to home mode.
  void _clearSearch() {
    _searchController.clear();

    setState(() {
      searchQuery = '';
      isSearching = false;
    });

    _clearSearchResultsOnly();
  }

  /// Clears search results and cancels old search requests.
  void _clearSearchResultsOnly() {
    _searchDebounce?.cancel();
    _searchRequestId++;

    setState(() {
      aiResults = [];
      isLoadingAiResults = false;
      aiSearchError = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Reusable UI helpers
  // ---------------------------------------------------------------------------

  Widget _buildLoadingBox() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildMessageBox(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(message),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header and search bar
  // ---------------------------------------------------------------------------

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.avif'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          leading: isSearching
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _clearSearch,
          )
              : Image.asset(
            'assets/icons/homepage_icon.png',
            color: Colors.deepPurple,
          ),
          title: const Text(
            'Tool Assistant',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Find, learn, and master AI models',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          final trimmedValue = value.trim();
          if (trimmedValue.isEmpty) return;

          _searchDebounce?.cancel();
          _searchWithAI(trimmedValue);
        },
        decoration: InputDecoration(
          hintText: 'What task do you need help with?',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search results UI
  // ---------------------------------------------------------------------------

  /// Builds the AI search result area.
  Widget _buildSearchResults() {
    if (isLoadingAiResults) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (aiSearchError != null) {
      final message = aiSearchError!.contains('429')
          ? 'Gemini rate limit reached. Wait about 30 seconds, then try again.'
          : 'Error: $aiSearchError';

      return Expanded(child: _buildMessageBox(message));
    }

    if (aiResults.isEmpty) {
      return Expanded(
        child: _buildMessageBox('No tools found for "$searchQuery"'),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: aiResults.length,
        itemBuilder: (context, index) {
          final tool = aiResults[index] as Map<String, dynamic>;
          return _buildSearchResultCard(tool);
        },
      ),
    );
  }

  /// Builds one AI result card.
  Widget _buildSearchResultCard(Map<String, dynamic> tool) {
    final name = (tool['name'] ?? tool['toolId'] ?? '').toString();
    final description = (tool['shortDescription'] ?? '').toString();
    final reason = (tool['reason'] ?? '').toString();
    final score = (tool['score'] ?? '').toString();
    final pricing = (tool['pricingModel'] ?? '').toString();

    final subtitleLines = [
      if (description.isNotEmpty) description,
      if (reason.isNotEmpty) 'Why: $reason',
      if (score.isNotEmpty) 'Match score: $score',
      if (pricing.isNotEmpty) 'Pricing: $pricing',
    ];

    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome),
        title: Text(name),
        subtitle: subtitleLines.isEmpty ? null : Text(subtitleLines.join('\n')),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          debugPrint('Clicked $name');
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Home content UI
  // ---------------------------------------------------------------------------

  /// Builds the home screen content.
  Widget _buildHomeContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('QUICK ACTIONS'),
            _buildQuickActionsSection(),
            const SizedBox(height: 16),
            _buildSectionTitle('POPULAR TOOLS'),
            _buildPopularToolsSection(),
          ],
        ),
      ),
    );
  }

  /// Builds the Quick Actions section.
  Widget _buildQuickActionsSection() {
    if (isLoadingQuickActions) {
      return _buildLoadingBox();
    }

    if (quickActionsError != null) {
      return _buildMessageBox('Error: $quickActionsError');
    }

    if (quickActionList.isEmpty) {
      return _buildMessageBox('No quick actions available.');
    }

    final itemCount = quickActionList.length > 4 ? 4 : quickActionList.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        return _buildQuickActionCard(quickActionList[index]);
      },
    );
  }

  /// Builds one Quick Action card.
  Widget _buildQuickActionCard(QuickActionItems item) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ToolsResultsPage(
                api: widget.api,
                taskId: item.taskId,
                taskLabel: item.taskName,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIcon(item.icon), size: 28),
              const SizedBox(height: 6),
              Text(item.taskName),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Popular Tools section.
  Widget _buildPopularToolsSection() {
    if (isLoadingPopularTools) {
      return _buildLoadingBox();
    }

    if (popularToolsError != null) {
      return _buildMessageBox('Error: $popularToolsError');
    }

    if (popularToolList.isEmpty) {
      return _buildMessageBox('No popular tools available.');
    }

    return Column(
      children: popularToolList.map(_buildPopularToolCard).toList(),
    );
  }

  /// Builds one Popular Tool card.
  ///
  /// When tapped, it opens ToolDetailPage.
  Widget _buildPopularToolCard(PopularToolcard item) {
    return ToolPreviewCard(
      toolName: item.toolName,
      iconKey: item.toolImage,
      shortDescription: item.shortDescription,
      pricingModel: item.pricingModel,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ToolDetailPage(
              toolId: item.toolId,
              toolName: item.toolName,
              toolImage: item.toolImage,
              shortDescription: item.shortDescription,
              pricingModel: item.pricingModel,
              isActive: item.isActive,
              isPopular: item.isPopular,
              platforms: item.platforms,
              websiteUrl: item.websiteUrl,
              popularityHint: item.popularityHint,
              taskIds: item.taskIds,
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Main layout
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),

                // Shows search results when typing, otherwise home content.
                if (isSearching) _buildSearchResults() else _buildHomeContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}