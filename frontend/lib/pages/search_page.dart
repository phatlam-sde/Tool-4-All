import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tool4all/api/api_client.dart';
import 'package:tool4all/models/PopularToolCard.dart';
import 'package:tool4all/models/QuickActionCard.dart';
import 'package:tool4all/pages/tools_results_page.dart';

/// Main search/home page for Tool4All.
///
/// This page has two modes:
/// 1. Home mode: shows quick actions and popular tools.
/// 2. Search mode: shows AI recommended tools based on what the user types.
///
/// The page needs an [ApiClient] so it can talk to FastAPI backend.
class search_page extends StatefulWidget {
  const search_page({super.key, required this.api});

  /// API client used to call backend routes such as:
  /// - GET /quick-actions
  /// - POST /tools/recommend
  final ApiClient api;

  @override
  State<search_page> createState() => _search_pageState();
}

class _search_pageState extends State<search_page> {
  // ---------------------------------------------------------------------------
  // Controllers and timers
  // ---------------------------------------------------------------------------

  /// Controls the text inside the search box.
  ///
  /// This lets us clear the actual text field when the user taps the back arrow.
  final TextEditingController _searchController = TextEditingController();

  /// Debounce timer for search.
  ///
  /// Without this, the app would call the backend on every typed character.
  /// With this timer, the app waits briefly after the user stops typing.
  Timer? _searchDebounce;

  // ---------------------------------------------------------------------------
  // Search state
  // ---------------------------------------------------------------------------

  /// True when the search box has text.
  ///
  /// When true, the page shows AI search results.
  /// When false, the page shows quick actions and popular tools.
  bool isSearching = false;

  /// Current text typed by the user.
  String searchQuery = '';

  // ---------------------------------------------------------------------------
  // Quick action state
  // ---------------------------------------------------------------------------

  /// Quick actions loaded from the backend.
  List<QuickActionItems> quickActionList = [];

  /// True while the app is loading quick actions from the backend.
  bool isLoadingQuickActions = true;

  /// Stores an error message if quick actions fail to load.
  String? quickActionsError;

  // ---------------------------------------------------------------------------
  // AI search state
  // ---------------------------------------------------------------------------

  /// Search results returned by the backend AI recommendation route.
  List<dynamic> aiResults = [];

  /// True while waiting for AI search results.
  bool isLoadingAiResults = false;

  /// Stores an error message if AI search fails.
  String? aiSearchError;

  /// Used to ignore old search responses.
  ///
  /// Example:
  /// - User searches "write".
  /// - User quickly changes it to "write resume".
  /// - The old "write" request finishes after the new request.
  ///
  /// This number helps the app ignore the old response.
  int _searchRequestId = 0;

  // ---------------------------------------------------------------------------
  // Static page data
  // ---------------------------------------------------------------------------

  /// Popular tools shown on the home page.
  ///
  /// These are currently hard-coded. Later, you can load them from the backend.
  final List<PopularToolcard> popularToolList = [
    PopularToolcard(toolImage: 'chat_bubble', toolName: 'ChatGPT'),
    PopularToolcard(toolImage: 'star', toolName: 'Jasper AI'),
    PopularToolcard(toolImage: 'chat_bubble', toolName: 'GitHub Copilot AI'),
  ];

  /// Converts icon names from the backend into real Flutter icons.
  ///
  /// Example:
  /// Backend sends: "code"
  /// Flutter displays: Icons.code
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

  /// Returns the matching icon for a string key.
  ///
  /// If the key does not exist, it uses Icons.help as a fallback.
  IconData _getIcon(String key) => _iconMap[key] ?? Icons.help;

  // ---------------------------------------------------------------------------
  // Lifecycle methods
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Load quick actions as soon as this page opens.
    _loadQuickActions();
  }

  @override
  void dispose() {
    // Always clean up controllers and timers when the page is removed.
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Backend calls
  // ---------------------------------------------------------------------------

  /// Loads quick action tasks from the backend.
  ///
  /// Expected backend route:
  /// GET /quick-actions
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

  /// Sends the user's query to the backend AI recommendation route.
  ///
  /// Expected backend route:
  /// POST /tools/recommend
  ///
  /// The backend should return a list of tools with fields like:
  /// - name
  /// - toolId
  /// - shortDescription
  /// - reason
  /// - score
  /// - pricingModel
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

      // Do not update the screen if this page is gone or this response is old.
      if (!mounted || currentRequestId != _searchRequestId) return;

      setState(() {
        aiResults = results;
        isLoadingAiResults = false;
      });
    } catch (e) {
      // Do not show errors from old requests.
      if (!mounted || currentRequestId != _searchRequestId) return;

      setState(() {
        aiSearchError = e.toString();
        isLoadingAiResults = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Search input handlers
  // ---------------------------------------------------------------------------

  /// Runs whenever the user types in the search box.
  ///
  /// This updates the local search text immediately, then waits 800ms before
  /// calling the backend. That delay is called a debounce.
  void _onSearchChanged(String value) {
    final trimmedValue = value.trim();

    setState(() {
      searchQuery = value;
      isSearching = trimmedValue.isNotEmpty;
    });

    // Cancel the previous timer because the user typed something new.
    _searchDebounce?.cancel();

    // If the search box is empty, reset the search state.
    if (trimmedValue.isEmpty) {
      _clearSearchResultsOnly();
      return;
    }

    // Wait briefly before searching so the backend is not called too often.
    _searchDebounce = Timer(const Duration(milliseconds: 800), () {
      _searchWithAI(trimmedValue);
    });
  }

  /// Clears the whole search box and returns the page to home mode.
  void _clearSearch() {
    _searchController.clear();

    setState(() {
      searchQuery = '';
      isSearching = false;
    });

    _clearSearchResultsOnly();
  }

  /// Clears only the search results/loading/error state.
  ///
  /// This also makes any unfinished backend search response become outdated.
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
  // Small UI helpers
  // ---------------------------------------------------------------------------

  /// Background image for the whole page.
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

  /// Top area containing the app bar and subtitle.
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

  /// Search input field.
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

  /// Reusable title for sections like QUICK ACTIONS and POPULAR TOOLS.
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
  // Search result UI
  // ---------------------------------------------------------------------------

  /// Builds the AI search result area.
  ///
  /// This method decides which search UI to show:
  /// - loading spinner
  /// - error message
  /// - no results message
  /// - list of recommended tools
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

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(message),
        ),
      );
    }

    if (aiResults.isEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text('No tools found for "$searchQuery"'),
        ),
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

  /// Builds the home content shown when the user is not searching.
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

  /// Builds the quick actions section.
  ///
  /// This section is loaded from the backend.
  Widget _buildQuickActionsSection() {
    if (isLoadingQuickActions) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (quickActionsError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error: $quickActionsError'),
      );
    }

    if (quickActionList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No quick actions available.'),
      );
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

  /// Builds one quick action card.
  ///
  /// When tapped, it opens [ToolsResultsPage] and passes the task id.
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

  /// Builds the full popular tools section.
  ///
  /// These tools are currently hard-coded in [popularToolList].
  Widget _buildPopularToolsSection() {
    return Column(
      children: popularToolList.map(_buildPopularToolCard).toList(),
    );
  }

  /// Builds one popular tool card.
  Widget _buildPopularToolCard(PopularToolcard item) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: Colors.grey, width: 1),
      ),
      child: InkWell(
        onTap: () {
          debugPrint('Clicked ${item.toolName}');
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(_getIcon(item.toolImage), size: 40),
              const SizedBox(width: 12),
              Expanded(child: Text(item.toolName)),
              const Icon(Icons.arrow_circle_right_outlined),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main page layout
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

                // Switch between search results and home content.
                if (isSearching) _buildSearchResults() else _buildHomeContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
