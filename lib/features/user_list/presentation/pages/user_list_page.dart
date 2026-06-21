import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../pace_selector/domain/entities/pace_entity.dart';
import '../../../pace_selector/presentation/bloc/swim_pace_bloc.dart';
import '../../../pace_selector/presentation/bloc/swim_pace_state.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/user_list_bloc.dart';
import '../bloc/user_list_event.dart';
import '../bloc/user_list_state.dart';
import 'user_detail_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _searchController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<UserListBloc>().add(FetchUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final swimState = context.watch<SwimPaceBloc>().state;
    final swimmerLevel = swimState.isSkipped
        ? SwimmerLevel.intermediate
        : swimState.level;
    final Color activeColor = AppTheme.getLevelColor(swimmerLevel);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          _buildHeader(context, activeColor, swimmerLevel, swimState),
          const SizedBox(height: 16),
          _buildSearchBar(activeColor),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<UserListBloc, UserListState>(
              builder: (context, state) {
                if (state.status == UserListStatus.loading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: activeColor,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (state.status == UserListStatus.failure) {
                  return _buildErrorView(
                    state.errorMessage ?? 'Something went wrong',
                    activeColor,
                  );
                }

                if (state.status == UserListStatus.success) {
                  if (state.filteredUsers.isEmpty) {
                    return _buildEmptyView(state.searchQuery);
                  }

                  return RefreshIndicator(
                    color: Colors.black,
                    backgroundColor: activeColor,
                    onRefresh: () async {
                      context.read<UserListBloc>().add(RefreshUsers());
                    },
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      itemCount: state.filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = state.filteredUsers[index];
                        return _buildUserCard(user, activeColor);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color activeColor,
    SwimmerLevel level,
    SwimPaceState swimState,
  ) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Users Directory",
            style: GoogleFonts.outfit(
              color: AppTheme.textWhite,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: AppTheme.textGrey.withValues(alpha: 0.7),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _searchController,
                style: GoogleFonts.inter(
                  color: AppTheme.textWhite,
                  fontSize: 15,
                ),
                cursorColor: activeColor,
                decoration: InputDecoration(
                  hintText: "Search user by name...",
                  hintStyle: GoogleFonts.inter(
                    color: AppTheme.textGrey.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  setState(() {});
                  context.read<UserListBloc>().add(SearchUsers(value));
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                  });
                  context.read<UserListBloc>().add(const SearchUsers(''));
                },
                icon: const Icon(
                  Icons.clear_rounded,
                  color: AppTheme.textGrey,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(UserEntity user, Color activeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserDetailPage(user: user, activeColor: activeColor),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.outfit(
                        color: activeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.outfit(
                          color: AppTheme.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 13,
                            color: AppTheme.textGrey.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              user.email,
                              style: AppTheme.subtitle.copyWith(
                                fontSize: 13,
                                color: AppTheme.textGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppTheme.textGrey.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              user.phone,
                              style: AppTheme.subtitle.copyWith(
                                fontSize: 13,
                                color: AppTheme.textGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: activeColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.redAccent.withValues(alpha: 0.7),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            "Connection Error",
            style: GoogleFonts.outfit(
              color: AppTheme.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.subtitle.copyWith(
              fontSize: 14,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<UserListBloc>().add(FetchUsers());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: activeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              "Try Again",
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppTheme.textGrey,
            size: 44,
          ),
          const SizedBox(height: 16),
          Text(
            "No matching users",
            style: GoogleFonts.outfit(
              color: AppTheme.textWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "We couldn't find any users named '$query'. Try another search term.",
            textAlign: TextAlign.center,
            style: AppTheme.subtitle.copyWith(
              fontSize: 13,
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}
