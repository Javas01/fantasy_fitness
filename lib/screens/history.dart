import 'package:fantasy_fitness/constants.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: supabase
          .from('fit_data')
          .select<List>()
          .eq('user_id', currUser?.id ?? ''),
      builder: (context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasError) {
          Future.delayed(const Duration(milliseconds: 100), () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error getting Data'),
              ),
            );
          });
          return Container();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          // List<HealthDataPoint> data = snapshot.data as List<HealthDataPoint>;
          return ListView.builder(
            itemCount: snapshot.data!.length,
            prototypeItem: ListTile(
              title: Text(
                snapshot.data!.first['data_type'],
              ),
              subtitle: Text(
                snapshot.data!.first['value'].toString(),
              ),
            ),
            itemBuilder: (BuildContext context, i) {
              return ListTile(
                title: Text(
                  snapshot.data![i]['data_type'],
                ),
                subtitle: Text(
                  snapshot.data![i]['value'].toString(),
                ),
              );
            },
          );
        }
      },
    );
  }
}
