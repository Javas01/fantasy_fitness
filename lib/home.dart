import 'package:fantasy_fitness/main.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('');
            } else {
              return Text(snapshot.data ?? '');
            }
          },
        ),
      ),
      body: ListView(
        children: [
          Row(
            children: [
              const Expanded(child: Center(child: Text('Challenge 1'))),
              IconButton(
                  onPressed: () {
                    // _supabaseClient.isLoggedIn(context);
                    getData();
                  },
                  icon: const Icon(Icons.arrow_forward))
            ],
          ),
          Row(
            children: [
              const Expanded(child: Center(child: Text('Challenge 2'))),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_forward))
            ],
          ),
          Row(
            children: [
              const Expanded(child: Center(child: Text('Challenge 3'))),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_forward))
            ],
          ),
          Row(
            children: [
              const Expanded(child: Center(child: Text('Challenge 4'))),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_forward))
            ],
          ),
          Row(
            children: [
              const Expanded(child: Center(child: Text('Challenge 5'))),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_forward))
            ],
          ),
          Row(
            children: [
              const Expanded(child: Center(child: Text('Challenge 6'))),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_forward))
            ],
          ),
          Row(
            children: [
              const Expanded(child: Center(child: Text('Challenge 7'))),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.arrow_forward))
            ],
          ),
        ],
      ),
    );
  }
}
