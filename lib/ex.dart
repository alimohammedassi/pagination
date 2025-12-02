import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Pang extends StatefulWidget {
  const Pang({super.key});

  @override
  State<Pang> createState() => _PangState();
}

class _PangState extends State<Pang> {
  // List to store all fetched items
  List<int> items = [];

  // Controller to monitor scroll position for pagination
  final ScrollController controller = ScrollController();

  // Flag to prevent multiple simultaneous data fetches
  bool loading = false;

  // Tracks which page of data we're currently on
  int currentPage = 1;

  // Number of items to fetch per page
  final pageSize = 30;

  // Maximum number of pages to load
  final maxPages = 4;

  /// Fetches a page of data from the "server" (simulated with delay)
  /// [page] - The page number to fetch
  ///
  /// FIXED: The calculation was wrong - it was multiplying (page-1) by pageSize twice
  /// Old: start = pageSize * (page-1) * pageSize
  /// New: start = pageSize * (page-1)
  Future<void> _fetchData(int page) async {
    // Set loading flag to true
    setState(() => loading = true);

    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Calculate starting index for this page
    // FIXED: Removed extra multiplication by pageSize
    final start = pageSize * (page - 1);

    // Generate new items for this page
    final newItems = List.generate(pageSize, (index) => start + index);

    // Add new items to the list and stop loading
    setState(() {
      items.addAll(newItems);
      loading = false;
    });
  }

  /// Initialize the widget state and set up scroll listener
  /// This runs once when the widget is first created
  @override
  void initState() {
    super.initState(); // MOVED: super.initState() should be called first

    // Load the first page of data
    _fetchData(currentPage);

    // Listen to scroll events for infinite scroll pagination
    controller.addListener(() {
      // Check if user scrolled near the bottom (within 100 pixels)
      // and we're not already loading and haven't reached max pages
      if (controller.position.pixels >=
              controller.position.maxScrollExtent - 100 &&
          !loading &&
          currentPage < maxPages) {
        // FIXED: Increment currentPage BEFORE fetching, not after
        // This prevents the same page from being fetched multiple times
        currentPage++;
        _fetchData(currentPage);
      }
    });
  }

  /// Clean up resources when widget is removed from the tree
  /// FIXED: Added @override annotation and moved super.dispose() to the end
  @override
  void dispose() {
    controller
        .dispose(); // Dispose the scroll controller to prevent memory leaks
    super.dispose(); // Call parent dispose method last
  }

  /// Builds the widget tree for this screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      body: Column(
        children: [
          // Main scrollable list of items
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    'Item ${items[index]}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),

          // Loading indicator shown at the bottom while fetching data
          if (loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CupertinoActivityIndicator(color: Colors.red, radius: 15),
            ),

          // Message shown when all pages have been loaded
          if (!loading && currentPage >= maxPages)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No more items to load',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
