import 'package:flutter/material.dart';

const _faqs = [
  (
    q: 'What is Gifthive?',
    a: 'Gifthive is the one and only place you need, to save all gift ideas for your loved ones. You can add, manage, and view all of your gift ideas in one place, so that you never forget what you were supposed to get dad for Father\'s day, or your sister on her next birthday!'
  ),
  (
    q: 'How do I get started?',
    a: 'Getting started is easy! First, create an account, then log in to access all the features. You can add, manage, and view your data through the user-friendly dashboard.'
  ),
  (
    q: 'Do I need to create an account?',
    a: 'Yes. In order to use the app, you must create an account. This allows you to save your data and access it from anywhere.'
  ),
  (
    q: 'What is a hive?',
    a: 'A hive is the collection holding all of the gift ideas for one person. You could also say that each hive represents a person in your life. You can create as many hives as you want and add as many items as you want to each hive.'
  ),
  (
    q: 'How do I add a new hive?',
    a: 'If it\'s your first time logging in, you will be prompted to create a new hive as soon as you are logged in. If you already have a hive, you can create a new one by tapping the \'+\' button on the dashboard or the hives screen.'
  ),
  (
    q: 'Can I change the name of a hive later?',
    a: 'This feature is coming soon!'
  ),
  (
    q: 'How do I delete a hive?',
    a: 'To delete a hive, tap the trash icon on the hive card. You will be asked to confirm before anything is deleted.'
  ),
  (
    q: 'How do I see the gifts inside a hive?',
    a: 'Tap on the hive name and you will be taken to a detail page showing all the gifts inside that hive.'
  ),
  (
    q: 'Can I mark a gift as bought?',
    a: 'Yes! Tap the checkbox next to a gift to toggle it between bought and not bought.'
  ),
  (
    q: 'Can I remove my account?',
    a: 'Yes! You can remove your account from the Account page.'
  ),
  (
    q: 'Can I update my username or password?',
    a: 'Yes! Simply fill out the form on the Account page to update your username or password.'
  ),
  (
    q: 'How do I share a hive?',
    a: 'Sharing is coming soon in the mobile app! In the meantime, you can share hives via the web version of Gifthive.'
  ),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + kBottomNavigationBarHeight + MediaQuery.viewPaddingOf(context).bottom),
        itemCount: _faqs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final faq = _faqs[i];
          return ExpansionTile(
            title: Text(faq.q, style: const TextStyle(fontWeight: FontWeight.w600)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(faq.a, style: const TextStyle(fontSize: 14))],
          );
        },
      ),
    );
  }
}
