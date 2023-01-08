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
          .eq('user_id', currUser?.id ?? '')
          .order('date_from'),
      builder: (context, snapshot) {
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
          return const Center(child: CircularProgressIndicator());
        } else {
          final data = HealthDataPoint.fromJson(snapshot.data!.first);

          return ListView.builder(
            itemCount: snapshot.data!.length,
            prototypeItem: ListTile(
              title: Text(
                data.typeString,
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${data.dateFrom}',
                  ),
                  Text(
                    '${data.dateTo}',
                  ),
                ],
              ),
              subtitle: Text(
                data.value.toString(),
              ),
            ),
            itemBuilder: (BuildContext context, i) {
              final data = HealthDataPoint.fromJson(snapshot.data![i]);

              return ListTile(
                title: Text(
                  data.typeString,
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${data.dateFrom}',
                    ),
                    Text(
                      '${data.dateTo}',
                    ),
                  ],
                ),
                subtitle: Text(
                  data.value.toString(),
                ),
              );
            },
          );
        }
      },
    );
  }
}
