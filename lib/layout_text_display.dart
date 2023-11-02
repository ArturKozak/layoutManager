import 'package:flutter/material.dart';

enum InfoType {
  privacy,
  terms,
}

class ParagraphModel {
  final String title;
  final String info;

  ParagraphModel({
    required this.title,
    required this.info,
  });
}

class ParagraphItem extends StatelessWidget {
  static const _bottomPadding = 4.0;
  static const _padding = 16.0;

  final ParagraphModel model;
  final TextStyle titleStyle;
  final TextStyle infoStyle;

  const ParagraphItem({
    required this.model,
    required this.infoStyle,
    required this.titleStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: _bottomPadding,
        top: _padding,
        left: _padding,
        right: _padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.title,
            style: titleStyle,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            model.info,
            style: infoStyle,
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }
}

class LayoutTextDisplay extends StatelessWidget {
  final TextStyle titleStyle;
  final TextStyle infoStyle;
  final TextStyle welcomeStyle;
  final String welcomeText;
  final InfoType type;
  final String companyName;
  final String email;

  const LayoutTextDisplay(
      {required this.titleStyle,
      required this.infoStyle,
      required this.welcomeStyle,
      required this.welcomeText,
      required this.type,
      required this.companyName,
      required this.email,
      super.key});

  @override
  Widget build(BuildContext context) {
    final privacy = [
      ParagraphModel(
        title: '''Information Collection and Use''',
        info:
            '''For a better experience, while using our Service, we may require you to provide us with certain personally identifiable information. The information that we request will be retained by us and used as described in this privacy policy.
\nThe app does use third party services that may collect information used to identify you.
\nLink to privacy policy of third party service providers used by the app
\n  * Firebase Analytics''',
      ),
      ParagraphModel(
        title: '''Log Data''',
        info:
            '''We want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics.''',
      ),
      ParagraphModel(
        title: '''Cookies''',
        info:
            '''Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device's internal memory.
This Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.
''',
      ),
      ParagraphModel(
        title: '''Service Providers''',
        info:
            '''We may employ third-party companies and individuals due to the following reasons:
\n  * To facilitate our Service;
\n  * To provide the Service on our behalf;
\n  * To perform Service-related services; or
\n  * To assist us in analyzing how our Service is used.
\nWe want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.
''',
      ),
      ParagraphModel(
        title: '''Security''',
        info:
            '''We value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security.''',
      ),
      ParagraphModel(
        title: '''Links to Other Sites''',
        info:
            '''This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.''',
      ),
      ParagraphModel(
        title: '''Children’s Privacy''',
        info:
            '''These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions.''',
      ),
      ParagraphModel(
        title: '''Changes to This Privacy Policy''',
        info:
            '''We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.''',
      ),
      ParagraphModel(
        title: '''Contact Us''',
        info:
            '''If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at $email''',
      ),
    ];

    final terms = [
      ParagraphModel(
        title: '''Use of the App''',
        info:
            '''\n1.1 Eligibility: You must be at least 18 years old or the legal age of majority in your jurisdiction to use the $companyName. By using the $companyName, you represent and warrant that you meet the eligibility requirements.
\n1.2 License: $companyName grants you a limited, non-exclusive, non-transferable, revocable license to use the $companyName for personal, non-commercial purposes. You agree not to reproduce, modify, distribute, sell, lease, or exploit any part of the $companyName without our prior written consent.
\n1.3 Account: In order to use certain features of the $companyName, you may be required to create an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.''',
      ),
      ParagraphModel(
        title: '''User Content''',
        info:
            '''\n2.1 Submission of User Content: The $companyName may allow you to submit or upload content, such as comments, reviews, or feedback ("User Content"). By submitting User Content, you grant $companyName a worldwide, non-exclusive, royalty-free, perpetual, irrevocable, and sublicensable license to use, reproduce, modify, adapt, publish, translate, distribute, perform, and display the User Content for any purpose.
\n2.2 Responsibility for User Content: You are solely responsible for the User Content you submit or upload. You agree not to submit any User Content that infringes upon the rights of others, is illegal, offensive, or violates any applicable laws or regulations. $companyName reserves the right to remove or refuse to display any User Content that violates this Agreement.''',
      ),
      ParagraphModel(
        title: '''Intellectual Property''',
        info:
            '''3.1 Ownership: The $companyName, including its design, graphics, and all intellectual property rights, are owned by $companyName or its licensors. This Agreement does not grant you any rights to use $companyName' trademarks, logos, or other proprietary materials.''',
      ),
      ParagraphModel(
        title: '''Privacy''',
        info:
            '''4.1 Privacy Policy: Your privacy is important to us. Our Privacy Policy explains how we collect, use, and disclose your personal information when you use the $companyName. By using the $companyName, you consent to our collection, use, and disclosure of your personal information as described in the Privacy Policy.''',
      ),
      ParagraphModel(
        title: '''Disclaimers and Limitation of Liability''',
        info:
            '''\n5.1 Warranty Disclaimer: The $companyName is provided on an "as is" and "as available" basis, without warranties of any kind, whether express or implied. $companyName disclaims all warranties, including but not limited to, implied warranties of merchantability, fitness for a particular purpose, and non-infringement.
\n5.2 Limitation of Liability: $companyName shall not be liable for any indirect, incidental, special, consequential, or exemplary damages arising out of or in connection with the use of the $companyName. To the maximum extent permitted by applicable law, $companyName' total liability for any claims under this Agreement shall not exceed the amount you paid (if any) to access or use the $companyName.''',
      ),
      ParagraphModel(
        title: '''Modifications to the Agreement''',
        info:
            '''$companyName reserves the right to modify or update this Agreement at any time, with or without notice. Your continued use of the $companyName after any modifications constitute your acceptance of the revised Agreement. It is your responsibility to review this Agreement periodically.''',
      ),
      ParagraphModel(
        title: '''Governing Law and Jurisdiction''',
        info:
            '''This Agreement shall be governed by and construed in accordance with the laws of the jurisdiction in which $companyName is located. Any disputes arising out of or in connection with this Agreement shall be subject to the exclusive jurisdiction of the courts in that jurisdiction.''',
      ),
      ParagraphModel(
        title: '''Entire Agreement''',
        info:
            '''This Agreement constitutes the entire agreement between you and $companyName regarding the $companyName and supersedes all prior agreements and understandings, whether written or oral.''',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              welcomeText,
              style: welcomeStyle,
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: type == InfoType.privacy ? privacy.length : terms.length,
            itemBuilder: (context, index) => ParagraphItem(
              model: type == InfoType.privacy ? privacy[index] : terms[index],
              infoStyle: infoStyle,
              titleStyle: titleStyle,
            ),
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}
