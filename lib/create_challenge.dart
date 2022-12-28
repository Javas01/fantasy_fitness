import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage(
      {super.key, required this.title, this.restorationId});

  final String title;
  final String? restorationId;

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage>
    with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTimeN _startDate = RestorableDateTimeN(DateTime.now());
  final RestorableDateTimeN _endDate =
      RestorableDateTimeN(DateTime.now().add(const Duration(days: 7)));
  late final RestorableRouteFuture<DateTimeRange?>
      _restorableDateRangePickerRouteFuture =
      RestorableRouteFuture<DateTimeRange?>(
    onComplete: _selectDateRange,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator
          .restorablePush(_dateRangePickerRoute, arguments: <String, dynamic>{
        'initialStartDate': _startDate.value?.millisecondsSinceEpoch,
        'initialEndDate': _endDate.value?.millisecondsSinceEpoch,
      });
    },
  );

  void _selectDateRange(DateTimeRange? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _startDate.value = newSelectedDate.start;
        _endDate.value = newSelectedDate.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: 'Challenge Name',
                ),
                const SizedBox(
                  height: 100,
                ),
                DropdownButtonFormField(
                  items: ['Running', 'Walking', 'Biking', 'Swimming', 'Hiking']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: const Text('Activity'),
                  icon: const Icon(Icons.run_circle_outlined),
                  onChanged: (Object? value) {},
                ),
                DropdownButtonFormField(
                  items: ['100 meters', '500 meters', '1 mile', '2 miles']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: const Text('Goal'),
                  icon: const Icon(Icons.gps_fixed_sharp),
                  onChanged: (Object? value) {},
                ),
                DropdownButtonFormField(
                  items: [
                    '24 hours',
                    '48 hours',
                    '1 week',
                    '2 weeks',
                    '1 month'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  hint: const Text('Window'),
                  icon: const Icon(Icons.timer),
                  onChanged: (Object? value) {},
                ),
                DropdownButtonFormField(
                  items: ['1\$', '2\$', '5\$', '10\$', '25\$']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  icon: const Icon(Icons.attach_money_rounded),
                  hint: const Text('Cost'),
                  onChanged: (Object? value) {},
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _restorableDateRangePickerRouteFuture.present();
                        },
                        child: Text(
                            '${_startDate.value != null ? DateFormat.yMEd().format(_startDate.value!) : ''} - ${_endDate.value != null ? DateFormat.yMEd().format(_endDate.value!) : ''}'),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Create'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_startDate, 'start_date');
    registerForRestoration(_endDate, 'end_date');
    registerForRestoration(
        _restorableDateRangePickerRouteFuture, 'date_picker_route_future');
  }

  static Route<DateTimeRange?> _dateRangePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTimeRange?>(
      context: context,
      builder: (BuildContext context) {
        return DateRangePickerDialog(
          restorationId: 'date_picker_dialog',
          initialDateRange:
              _initialDateTimeRange(arguments! as Map<dynamic, dynamic>),
          firstDate: DateTime(2022),
          currentDate: DateTime.now(),
          lastDate: DateTime(2024),
        );
      },
    );
  }

  static DateTimeRange? _initialDateTimeRange(Map<dynamic, dynamic> arguments) {
    if (arguments['initialStartDate'] != null &&
        arguments['initialEndDate'] != null) {
      return DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(
            arguments['initialStartDate'] as int),
        end: DateTime.fromMillisecondsSinceEpoch(
            arguments['initialEndDate'] as int),
      );
    }

    return null;
  }
}
