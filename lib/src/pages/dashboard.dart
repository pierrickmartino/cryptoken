import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/api.dart';
import '../app.dart';
import '../widgets/portfolio_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return FutureBuilder<List<Portfolio>>(
      future: appState.api.portfolios.list(),
      builder: (context, futureSnapshot) {
        if (!futureSnapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder<List<Portfolio>>(
          initialData: futureSnapshot.data,
          stream: appState.api.portfolios.subscribe(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Dashboard(portfolios: snapshot.data);
          },
        );
      },
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key, this.portfolios}) : super(key: key);

  final List<Portfolio>? portfolios;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<AppState>(context).api;
    return Scrollbar(
      child: Container(
        color: const Color(0xff3A6EA5),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: GridView(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 1200,
              mainAxisExtent: 350, // adjust the height of the position widget
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            children: [
              ...portfolios!.map(
                (portfolio) => Card(
                  color: const Color(0xffEBEBEB),
                  child: PortfolioWidget(
                    api: api,
                    portfolio: portfolio,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
