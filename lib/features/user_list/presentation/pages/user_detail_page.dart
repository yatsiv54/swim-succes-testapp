import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';

class UserDetailPage extends StatelessWidget {
  final UserEntity user;
  final Color activeColor;

  const UserDetailPage({
    super.key,
    required this.user,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundCard, AppTheme.backgroundDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileSummary(),
                      const SizedBox(height: 28),
                      _buildSectionHeader("CONTACT DETAILS"),
                      const SizedBox(height: 12),
                      _buildContactCard(),
                      const SizedBox(height: 24),
                      _buildSectionHeader("ADDRESS"),
                      const SizedBox(height: 12),
                      _buildAddressCard(),
                      const SizedBox(height: 24),
                      _buildSectionHeader("COMPANY"),
                      const SizedBox(height: 12),
                      _buildCompanyCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textWhite,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.borderGrey),
              ),
            ),
          ),
          Text(
            "User Details",
            style: GoogleFonts.outfit(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }

  Widget _buildProfileSummary() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: activeColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: activeColor.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: GoogleFonts.outfit(
                color: activeColor,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: AppTheme.textWhite,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "@${user.username}",
          style: AppTheme.subtitle.copyWith(
            color: activeColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.labelSmall.copyWith(
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            title: "Email",
            value: user.email,
          ),
          const Divider(color: AppTheme.borderGrey, height: 28),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            title: "Phone",
            value: user.phone,
          ),
          const Divider(color: AppTheme.borderGrey, height: 28),
          _buildInfoRow(
            icon: Icons.language_rounded,
            title: "Website",
            value: user.website,
            valueColor: activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.home_work_outlined,
            title: "Street & Suite",
            value: "${user.address.suite}, ${user.address.street}",
          ),
          const Divider(color: AppTheme.borderGrey, height: 28),
          _buildInfoRow(
            icon: Icons.location_city_outlined,
            title: "City & Zip",
            value: "${user.address.city} (${user.address.zipcode})",
          ),
          const Divider(color: AppTheme.borderGrey, height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                color: activeColor,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Geo Coordinates",
                      style: AppTheme.subtitle.copyWith(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildCoordBadge("LAT", user.address.geo.lat),
                        const SizedBox(width: 8),
                        _buildCoordBadge("LNG", user.address.geo.lng),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business_rounded,
                  color: activeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Company Name",
                      style: AppTheme.subtitle.copyWith(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.company.name,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppTheme.borderGrey, height: 28),
          _buildInfoRow(
            icon: Icons.lightbulb_outline_rounded,
            title: "Catch Phrase",
            value: '"${user.company.catchPhrase}"',
            italic: true,
          ),
          const Divider(color: AppTheme.borderGrey, height: 28),
          _buildInfoRow(
            icon: Icons.track_changes_rounded,
            title: "Business Strategy (BS)",
            value: user.company.bs.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    bool italic = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: activeColor,
          size: 20,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.subtitle.copyWith(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: valueColor ?? AppTheme.textWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoordBadge(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Text(
        "$label: $val",
        style: GoogleFonts.atkinsonHyperlegibleMono(
          color: AppTheme.textWhite,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
