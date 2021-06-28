import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_dashboard/src/widgets/dialogs.dart';
import '../../src/api/api.dart';

import '../constants.dart';

class FileInfoCard extends StatefulWidget {
  const FileInfoCard({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  final Portfolio portfolio;

  @override
  State<FileInfoCard> createState() => _FileInfoCardState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _FileInfoCardState extends State<FileInfoCard> {
  Color boxDecorationColor = secondaryColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          boxDecorationColor == secondaryColor
              ? boxDecorationColor = quaternaryColor
              : boxDecorationColor = secondaryColor;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: boxDecorationColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(defaultPadding * 0.75),
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: primaryColor
                        .withOpacity(0.1), // portfolio.color!.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: SvgPicture.asset(
                    'icons/folder.svg', //portfolio.svgSrc!,
                    color: primaryColor, // portfolio.color,
                  ),
                ),
                PopupMenuButton(
                  color: secondaryColor,
                  onSelected: (value) {
                    switch (value) {
                      case 1:
                        showDialog<EditPortfolioDialog>(
                          context: context,
                          builder: (context) {
                            return EditPortfolioDialog(
                              portfolio: widget.portfolio,
                            );
                          },
                        );
                        break;
                      case 2:
                        showGeneralDialog<NewTransactionDialog>(
                          context: context,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  NewTransactionDialog(
                            selectedPortfolio: widget.portfolio,
                          ),
                        );
                        break;
                      default:
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 1,
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 2,
                      child: Text('Add transaction'),
                    )
                  ],
                )
              ],
            ),
            Text(
              widget.portfolio.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const ProgressLine(
              // color: portfolio.color,
              percentage: 10, //portfolio.percentage,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '10 Files',
                  //'${portfolio.numOfFiles} Files',
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white70),
                ),
                Text(
                  '1.2GB', //portfolio.totalStorage!,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    Key? key,
    this.color = primaryColor,
    required this.percentage,
  }) : super(key: key);

  final Color? color;
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withOpacity(0.1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            width: constraints.maxWidth * (percentage! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
