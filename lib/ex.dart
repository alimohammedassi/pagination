import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Pang extends StatefulWidget {
  const Pang({super.key});

  @override
  State<Pang> createState() => _PangState();
}

class _PangState extends State<Pang> {
  List<int> items = [];
  final ScrollController controller = ScrollController();
  bool loading = false;
  int currentPage = 1;
  final pageSize = 30;
  final maxPages = 4;

  Future<void> _fetchData(int page) async {
    setState(() => loading = true);
    await Future.delayed( Duration(seconds: 2));
    final start=pageSize*(page-1)*pageSize;
    final newItems =List.generate(pageSize, (index) => start+index);
    setState(() {
      items.addAll(newItems);
      setState(() => loading = false);
    });  
    
  
  }

  @override
  
  void initState() {
    _fetchData(currentPage);

    controller.addListener(() {
      if (controller.position.pixels >=
              controller.position.maxScrollExtent - 100 &&
          !loading &&
          currentPage < maxPages) {
        _fetchData(currentPage++);
      }
    });
    super.initState();
  }
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,

      body: Column(
        children: [
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
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: CupertinoActivityIndicator(color: Colors.red, radius: 15),
            ),
          if (!loading && currentPage >= maxPages)
            Padding(
              padding: const EdgeInsets.all(20),
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
