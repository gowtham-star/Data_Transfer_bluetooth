import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'databasehelper.dart';

class ChartsPage extends StatelessWidget {
  final List<PiDataModel> databaseData;

  ChartsPage({required this.databaseData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Charts Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Temperature Chart", style: TextStyle(fontSize: 16)),
              SfCartesianChart(
                primaryXAxis: DateTimeAxis(title: AxisTitle(
                    text: 'Time'
                )),primaryYAxis: NumericAxis(
                  title: AxisTitle(
                      text: 'Temperature'
                  )
              ),
                series: <ChartSeries<PiDataModel, DateTime>>[
                  LineSeries<PiDataModel, DateTime>(
                    dataSource: databaseData,
                    xValueMapper: (PiDataModel timeseriesdata, _) =>
                        DateTime.fromMillisecondsSinceEpoch(timeseriesdata.timeStamp),
                    yValueMapper: (PiDataModel timeseriesdata, _) =>
                    timeseriesdata.temperature,
                  ),
                ],
              ),
              Text("Random Chart", style: TextStyle(fontSize: 16)),
              SfCartesianChart(
                primaryXAxis: DateTimeAxis(title: AxisTitle(
                    text: 'Time'
                )),
                primaryYAxis: NumericAxis(title: AxisTitle(text: "Random")),
                series: <ChartSeries<PiDataModel, DateTime>>[
                  LineSeries<PiDataModel, DateTime>(
                    dataSource: databaseData,
                    xValueMapper: (PiDataModel timeseriesdata, _) =>
                        DateTime.fromMillisecondsSinceEpoch(timeseriesdata.timeStamp),
                    yValueMapper: (PiDataModel timeseriesdata, _) =>
                    timeseriesdata.random,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
