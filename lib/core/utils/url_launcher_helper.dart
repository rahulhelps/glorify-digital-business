import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  static Future<void> launchWhatsApp(BuildContext context, String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    final nativeUrl = Uri.parse('whatsapp://send?phone=$cleanNumber');
    final webUrl = Uri.parse('https://wa.me/$cleanNumber');

    try {
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  static Future<void> launchTelegram(BuildContext context, String username) async {
    final cleanUsername = username.replaceAll('@', '').trim();
    final nativeUrl = Uri.parse('tg://resolve?domain=$cleanUsername');
    final webUrl = Uri.parse('https://t.me/$cleanUsername');

    try {
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Telegram')),
      );
    }
  }

  static Future<void> launchFacebook(BuildContext context, String fbUrl) async {
    final url = Uri.parse(fbUrl);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Facebook')),
      );
    }
  }

  static Future<void> launchPhoneCall(BuildContext context, String number) async {
    final cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not initiate phone call')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not initiate phone call')),
      );
    }
  }
}
