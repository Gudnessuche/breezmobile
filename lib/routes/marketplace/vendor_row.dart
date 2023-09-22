import 'package:breez/bloc/account/account_bloc.dart';
import 'package:breez/bloc/blocs_provider.dart';
import 'package:breez/bloc/lnurl/lnurl_bloc.dart';
import 'package:breez/bloc/marketplace/vendor_model.dart';
import 'package:breez/routes/marketplace/lnurl_auth.dart';
import 'package:breez/theme_data.dart' as theme;
import 'package:breez/widgets/error_dialog.dart';
import 'package:breez/widgets/route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'lnurl_webview.dart';
import 'vendor_webview.dart';

class VendorRow extends StatelessWidget {
  final AccountBloc accountBloc;
  final VendorModel _vendor;

  const VendorRow(this.accountBloc, this._vendor);

  @override
  Widget build(BuildContext context) {
    var lnurlBloc = AppBlocsProvider.of<LNUrlBloc>(context);
    Color vendorFgColor =
        theme.vendorTheme[_vendor.id.toLowerCase()]?.iconFgColor ??
            Colors.transparent;
    Color vendorBgColor =
        theme.vendorTheme[_vendor.id.toLowerCase()]?.iconBgColor ??
            Colors.white;
    Color vendorTextColor =
        theme.vendorTheme[_vendor.id.toLowerCase()]?.textColor ?? Colors.black;

    final vendorLogo = _vendor.logo != null
        ? Image(
            image: AssetImage(_vendor.logo),
            height: (_vendor.id == 'Wavlake')
                ? 73
                : (_vendor.id == 'LNCal')
                    ? 56
                    : (_vendor.id == 'Snort')
                        ? 100
                        : 48,
            width: _vendor.onlyShowLogo
                ? (_vendor.id == 'Bitrefill')
                    ? 156
                    : 196
                : null,
            color: vendorFgColor,
            colorBlendMode: BlendMode.srcATop,
          )
        : Container();

    final vendorCard = GestureDetector(
        onTap: () async {
          // iOS only
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            try {
              var url = _vendor.url;
              if (_vendor.id == "lnmarkets" || _vendor.id == "Kollider") {
                final endpointURI = _vendor.id == "lnmarkets"
                    ? Uri.https("api.lnmarkets.com", "v1/lnurl/auth")
                    : Uri.https(
                        "api.kollider.xyz", "v1/auth/external/lnurl_auth");
                var responseID =
                    _vendor.id == "lnmarkets" ? "lnurl" : "lnurl_auth";
                var jwtToken = await handleLNUrlAuth(
                    context, _vendor, endpointURI, lnurlBloc, responseID);
                url = "$url?token=$jwtToken";
              }
              launchUrl(Uri.parse(url));
            } catch (err) {
              promptError(context, "Error", Text(err.toString()));
            }
            return;
          }

          // non iOS
          Navigator.push(context, FadeInRoute(
            builder: (_) {
              if (_vendor.endpointURI != null) {
                var lnurlBloc = AppBlocsProvider.of<LNUrlBloc>(context);
                return LNURLWebViewPage(
                  accountBloc: accountBloc,
                  vendorModel: _vendor,
                  lnurlBloc: lnurlBloc,
                  endpointURI: Uri.tryParse(_vendor.endpointURI),
                  responseID: _vendor.responseID,
                );
              }
              return VendorWebViewPage(
                  accountBloc, _vendor.url, _vendor.displayName);
            },
          ));
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 8.0),
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
              color: vendorBgColor,
              boxShadow: [
                BoxShadow(
                  color: theme.BreezColors.grey[600],
                  blurRadius: 8.0,
                )
              ],
              border: Border.all(
                  color: vendorBgColor == Colors.white
                      ? Theme.of(context).highlightColor
                      : Colors.transparent,
                  style: BorderStyle.solid,
                  width: 1.0),
              borderRadius: BorderRadius.circular(14.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _buildLogo(vendorLogo, vendorTextColor),
          ),
        ));

    return vendorCard;
  }

  List<Widget> _buildLogo(Widget vendorLogo, vendorTextColor) {
    if (_vendor.onlyShowLogo) {
      return <Widget>[vendorLogo];
    } else {
      return <Widget>[
        vendorLogo,
        const Padding(padding: EdgeInsets.only(left: 8.0)),
        Text(_vendor.displayName,
            style: theme.vendorTitleStyle.copyWith(color: vendorTextColor)),
      ];
    }
  }
}
