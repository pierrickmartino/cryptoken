import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:web_dashboard/settings/view/settings.dart';

import '../../../constant.dart';
import '../../../wallet/view/new_wallet.dart';
import '../../responsive.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {}, //context.read<MenuController>().controlMenu,
          ),
        if (!Responsive.isMobile(context))
          Wrap(
            spacing: 5,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headline6,
              ),
              const Text('v1.1.5', textScaleFactor: 0.8),
            ],
          ),
        if (!Responsive.isMobile(context))
          Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
        const Expanded(
            child: Text('') /*SearchField()*/), // not necessary at the moment

        // if we are on Mobile we only want to show icon to keep space on screen
        if (Responsive.isMobile(context))
          IconButton(
            onPressed: () {
              showDialog<NewWalletDialog>(
                context: context,
                builder: (context) => const NewWalletDialog(),
              );
            },
            icon: const Icon(Icons.add),
          ),

        // otherwise we can show a lable with the button icon
        if (!Responsive.isMobile(context))
          ElevatedButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: defaultPadding * 1.5,
                vertical:
                    defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
              ),
            ),
            onPressed: () {
              showDialog<NewWalletDialog>(
                context: context,
                builder: (context) => const NewWalletDialog(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Wallet'),
          ),

        const ProfileCard()
      ],
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          if (!Responsive.isMobile(context))
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Text('Angelina Joli'),
            ),
          PopupMenuButton(
            color: secondaryColor,
            icon: const Icon(Icons.keyboard_arrow_down),
            onSelected: (value) async {
              switch (value) {
                case 1:
                  final data = await Get.to<SettingsUI>(const SettingsUI());
                  if (data == 'success') {
                    debugPrint('refresh');
                  }
                  break;

                default:
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        fillColor: secondaryColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset('icons/Search.svg'),
          ),
        ),
      ),
    );
  }
}
