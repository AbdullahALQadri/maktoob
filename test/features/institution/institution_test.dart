import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/api/api_consumer.dart';
import 'package:maktoob/core/api/event_wizard_api_service.dart';
import 'package:maktoob/core/error/exceptions.dart';
import 'package:maktoob/core/error/failures.dart';
import 'package:maktoob/core/error/institution_errors.dart';
import 'package:maktoob/features/authentication/data/models/auth_response_model.dart';
import 'package:maktoob/features/authentication/domain/entities/user_entity.dart';
import 'package:maktoob/features/events/data/models/event_model.dart';
import 'package:maktoob/features/institution/data/models/institution_models.dart';
import 'package:maktoob/features/institution/domain/entities/event_role.dart';
import 'package:maktoob/features/institution/domain/entities/institution_entity.dart';
import 'package:maktoob/features/institution/domain/repositories/institution_repository.dart';
import 'package:maktoob/features/institution/presentation/cubit/institution_cubit.dart';
import 'package:maktoob/features/institution/presentation/cubit/institution_state.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_cubit.dart';
import 'package:maktoob/features/invitation/presentation/cubit/invitation_state.dart';

Map<String, dynamic> _client({String status = 'approved', List memberships = const []}) => {
      'id': 5,
      'name': 'Owner',
      'phone': '+970599000000',
      'is_verified': true,
      'account_type': 'institution',
      'institution_status': status,
      'institution': {
        'id': 9,
        'status': status,
        'name_ar': 'شركة الأمل',
        'name_en': 'Amal Co',
        'sector': 'company',
        'logo_url': 'https://cdn.example.com/l.png',
        'rejection_reason': status == 'rejected' ? 'الوثائق ناقصة' : null,
        'discount_percent': '10.00',
        'invitation_credits': 120,
      },
      'institution_memberships': memberships,
    };

class _FakeRepo implements InstitutionRepository {
  final members = <InstitutionMemberEntity>[
    const InstitutionMemberEntity(id: 1, phone: '0599111222', role: 'viewer', status: 'active'),
  ];
  final invites = <PendingInviteEntity>[
    const PendingInviteEntity(id: 3, role: 'manager', institutionName: 'جمعية'),
  ];
  bool failNext = false;

  InstitutionOverviewEntity get _overview =>
      InstitutionOverviewEntity(pendingInvites: List.of(invites));

  Future<Either<Failure, T>> _r<T>(T value) async {
    if (failNext) {
      failNext = false;
      return const Left(ServerFailure(message: 'boom'));
    }
    return Right(value);
  }

  @override
  Future<Either<Failure, InstitutionOverviewEntity>> getOverview() => _r(_overview);
  @override
  Future<Either<Failure, InstitutionOverviewEntity>> saveProfile(InstitutionProfileInput input) => _r(
        InstitutionOverviewEntity(
          isInstitutionAccount: true,
          institution: InstitutionEntity(id: 1, status: InstitutionStatus.pending, nameAr: input.nameAr),
        ),
      );
  @override
  Future<Either<Failure, List<InstitutionMemberEntity>>> getMembers() => _r(List.of(members));
  @override
  Future<Either<Failure, void>> inviteMember({required String phone, required String role}) {
    members.add(InstitutionMemberEntity(id: members.length + 1, phone: phone, role: role));
    return _r(null);
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(int memberId, String role) {
    final i = members.indexWhere((m) => m.id == memberId);
    members[i] = InstitutionMemberEntity(id: memberId, phone: members[i].phone, role: role);
    return _r(null);
  }

  @override
  Future<Either<Failure, void>> removeMember(int memberId) {
    members.removeWhere((m) => m.id == memberId);
    return _r(null);
  }

  @override
  Future<Either<Failure, void>> acceptInvite(int inviteId) {
    invites.removeWhere((i) => i.id == inviteId);
    return _r(null);
  }

  @override
  Future<Either<Failure, void>> declineInvite(int inviteId) => acceptInvite(inviteId);

  final documents = <InstitutionDocumentEntity>[];

  InstitutionOverviewEntity get _withDocs => InstitutionOverviewEntity(
        isInstitutionAccount: true,
        institution: InstitutionEntity(
          id: 1,
          status: InstitutionStatus.pending,
          nameAr: 'جمعية',
          documents: List.of(documents),
        ),
      );

  @override
  Future<Either<Failure, InstitutionOverviewEntity>> uploadDocument({required String type, required String filePath}) {
    documents.add(InstitutionDocumentEntity(id: documents.length + 1, type: type, originalName: filePath.split('/').last));
    return _r(_withDocs);
  }

  @override
  Future<Either<Failure, InstitutionOverviewEntity>> deleteDocument(int documentId) {
    documents.removeWhere((d) => d.id == documentId);
    return _r(_withDocs);
  }
  @override
  Future<Either<Failure, InstitutionCreditsEntity>> getCredits() =>
      _r(const InstitutionCreditsEntity(balance: 40));
}

class _FakeApi implements ApiConsumer {
  final bodies = <String, Map<String, dynamic>?>{};

  @override
  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async {
    bodies[path] = body;
    return {'success': true, 'data': {'event_id': 77}};
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async => {'success': true, 'data': {}};
  @override
  Future<dynamic> put(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async => {};
  @override
  Future<dynamic> delete(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters}) async => {};
  @override
  Future<dynamic> postWithImage(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => {};
  @override
  Future<dynamic> postCreateService(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => {};
  @override
  Future<dynamic> postRegister(String path, {Map<String, dynamic>? body, Map<String, dynamic>? queryParameters, dynamic params}) async => {};
}

void main() {
  group('models', () {
    test('client payload maps account type, status, institution and memberships', () {
      final user = ClientModel.fromJson(_client(memberships: [
        {'membership_id': 2, 'institution_id': 4, 'institution_name': 'جمعية', 'institution_status': 'approved', 'owner_client_id': 8, 'role': 'manager'},
        {'membership_id': 3, 'institution_id': 6, 'institution_name': 'معلقة', 'institution_status': 'pending', 'role': 'manager'},
        {'membership_id': 4, 'institution_id': 7, 'institution_name': 'عرض', 'institution_status': 'approved', 'role': 'viewer'},
      ])).toEntity();

      expect(user.userType, UserType.institution);
      expect(user.institutionStatus, InstitutionStatus.approved);
      expect(user.institution!.discountPercent, 10);
      expect(user.institution!.invitationCredits, 120);
      expect(user.needsInstitutionApproval, isFalse);
      // Own approved institution + approved manager membership only.
      expect(user.eventOwnerChoices.map((c) => c.institutionId), [9, 4]);
      expect(user.eventOwnerChoices.first.credits, 120);
    });

    test('pending / rejected institutions need approval; individuals never do', () {
      expect(ClientModel.fromJson(_client(status: 'pending')).toEntity().needsInstitutionApproval, isTrue);
      final rejected = ClientModel.fromJson(_client(status: 'rejected')).toEntity();
      expect(rejected.needsInstitutionApproval, isTrue);
      expect(rejected.institution!.rejectionReason, 'الوثائق ناقصة');
      expect(rejected.eventOwnerChoices, isEmpty);

      final individual = ClientModel.fromJson({'id': 1, 'name': 'A', 'phone': '1', 'account_type': 'individual'}).toEntity();
      expect(individual.needsInstitutionApproval, isFalse);
      expect(individual.eventOwnerChoices, isEmpty);
    });

    test('overview, members and credits parse the envelope', () {
      final overview = InstitutionOverviewModel.fromJson({
        'success': true,
        'data': {
          'account_type': 'institution',
          'institution': {'id': 1, 'status': 'pending', 'name_ar': 'x'},
          'memberships': [],
          'pending_invites': [
            {'id': 3, 'role': 'door_staff', 'institution_id': 2, 'institution_name': 'y', 'invited_at': '2026-10-01'},
          ],
        },
      });
      expect(overview.isInstitutionAccount, isTrue);
      expect(overview.institution!.status, InstitutionStatus.pending);
      expect(overview.pendingInvites.single.role, 'door_staff');

      final members = InstitutionMemberModel.listFrom({
        'data': {
          'members': [
            {'id': 1, 'phone': '+970599', 'role': 'manager', 'status': 'active'},
            {'id': 2, 'phone': '+970598', 'role': 'viewer', 'accepted_at': null},
          ],
        },
      });
      expect(members.first.isActive, isTrue);
      expect(members.last.status, 'invited');

      final credits = InstitutionCreditsModel.fromJson({
        'data': {
          'balance': 30,
          'discount_percent': 5,
          'transactions': [
            {'id': 1, 'type': 'usage', 'amount': -20, 'balance_after': 30, 'event_id': 4, 'created_at': '2026-10-10T10:00:00Z'},
          ],
        },
      });
      expect(credits.balance, 30);
      expect(credits.transactions.single.amount, -20);
      expect(credits.transactions.single.createdAt, isNotNull);
    });

    test('profile input sends backend field names', () {
      const input = InstitutionProfileInput(nameAr: 'شركة', sector: 'ngo', contactPerson: '');
      expect(input.toFields(), {'organization_name_ar': 'شركة', 'sector': 'ngo'});
    });
  });

  group('role gating', () {
    test('ability matrix mirrors EventAccess', () {
      expect(EventRole.fromString(null), EventRole.owner);
      final owner = EventRole.owner, manager = EventRole.manager;
      final door = EventRole.fromString('door_staff'), viewer = EventRole.fromString('viewer');

      expect([owner.canOwn, manager.canOwn, door.canOwn, viewer.canOwn], [true, false, false, false]);
      expect([owner.canManage, manager.canManage, door.canManage, viewer.canManage], [true, true, false, false]);
      expect([owner.canScan, manager.canScan, door.canScan, viewer.canScan], [true, true, true, false]);
      expect([owner.canView, manager.canView, door.canView, viewer.canView], [true, true, false, true]);
      expect(door.isScannerOnly, isTrue);
      expect(viewer.isReadOnly, isTrue);
    });

    test('events carry my_role', () {
      final e = EventModel.fromJson({'id': 1, 'title': 'x', 'status': 'active', 'my_role': 'viewer'});
      expect(e.role, EventRole.viewer);
      expect(e.copyWith(name: 'y').myRole, 'viewer');
      expect(EventModel.fromJson({'id': 2, 'title': 'z', 'status': 'active'}).role, EventRole.owner);
    });
  });

  group('errors', () {
    test('institution_not_approved: 403 code and activation blocker', () {
      expect(isInstitutionNotApproved(const InstitutionNotApprovedException(message: 'm')), isTrue);
      expect(isInstitutionNotApproved(const ValidationException(blockers: ['institution_not_approved'])), isTrue);
      expect(isInstitutionNotApproved(const ValidationException(blockers: ['free_trial_used'])), isFalse);
      expect(isInstitutionNotApproved(const UnauthorizedException()), isFalse);
    });
  });

  group('packages & credits', () {
    test('final price, private badge and credits coverage', () {
      final pkg = PackageModel.fromJson({
        'id': 2, 'name_ar': 'أساسية', 'price': '100.00', 'final_price': 90, 'discount_percent': 10,
        'is_private': true, 'invitations_limit': 50,
      });
      expect(pkg.effectivePrice, 90);
      expect(pkg.hasDiscount, isTrue);
      expect(pkg.isPrivate, isTrue);

      var state = const InvitationState().copyWith(selectedPackage: pkg);
      expect(state.creditsCoverSelectedPackage, isFalse); // personal account
      state = state.copyWith(institutionId: 9, institutionCredits: 49);
      expect(state.creditsCoverSelectedPackage, isFalse);
      state = state.copyWith(institutionCredits: 50);
      expect(state.creditsCoverSelectedPackage, isTrue);
    });

    test('wizard sends institution_id when creating for an institution', () async {
      final api = _FakeApi();
      final service = EventWizardApiService(apiConsumer: api);
      await service.initializeWizard(eventTypeId: 1, institutionId: 9);
      expect(api.bodies['/event-wizard/initialize']!['institution_id'], 9);
      await service.initializeWizard(eventTypeId: 1);
      expect(api.bodies['/event-wizard/initialize']!.containsKey('institution_id'), isFalse);

      final cubit = InvitationCubit(apiService: service);
      cubit.setEventOwner(institutionId: 9, institutionName: 'شركة', credits: 10);
      expect(cubit.state.institutionId, 9);
      cubit.setEventOwner();
      expect(cubit.state.institutionId, isNull);
      await cubit.close();
    });
  });

  group('cubits', () {
    test('InstitutionCubit loads, saves and accepts invites', () async {
      final repo = _FakeRepo();
      final cubit = InstitutionCubit(repository: repo);
      await cubit.load();
      expect((cubit.state as InstitutionLoaded).overview.pendingInvites, hasLength(1));

      await cubit.acceptInvite(3);
      final s = cubit.state as InstitutionLoaded;
      expect(s.overview.pendingInvites, isEmpty);
      expect(s.message, 'institution_invite_accepted');

      expect(await cubit.saveProfile(const InstitutionProfileInput(nameAr: 'جديد')), isTrue);
      expect((cubit.state as InstitutionLoaded).overview.institution!.nameAr, 'جديد');

      repo.failNext = true;
      expect(await cubit.saveProfile(const InstitutionProfileInput(nameAr: 'x')), isFalse);
      expect((cubit.state as InstitutionLoaded).messageIsError, isTrue);
      await cubit.close();
    });

    test('InstitutionCubit uploads and deletes verification documents', () async {
      final repo = _FakeRepo();
      final cubit = InstitutionCubit(repository: repo);
      await cubit.load();

      expect(await cubit.uploadDocument(type: 'registration_certificate', filePath: '/tmp/cert.pdf'), isTrue);
      var s = cubit.state as InstitutionLoaded;
      expect(s.overview.institution!.documents.single.originalName, 'cert.pdf');
      expect(s.message, 'institution_document_uploaded');
      // Pending invites survive a response that does not carry them.
      expect(s.overview.pendingInvites, hasLength(1));

      expect(await cubit.deleteDocument(1), isTrue);
      s = cubit.state as InstitutionLoaded;
      expect(s.overview.institution!.documents, isEmpty);
      expect(s.message, 'institution_document_deleted');

      repo.failNext = true;
      expect(await cubit.uploadDocument(type: 'other', filePath: '/tmp/x.pdf'), isFalse);
      expect((cubit.state as InstitutionLoaded).messageIsError, isTrue);
      await cubit.close();
    });

    test('InstitutionTeamCubit invites, changes role and removes', () async {
      final repo = _FakeRepo();
      final cubit = InstitutionTeamCubit(repository: repo);
      await cubit.load();
      expect(await cubit.invite(phone: '0599333444', role: 'door_staff'), isTrue);
      expect((cubit.state as InstitutionTeamLoaded).members, hasLength(2));
      await cubit.changeRole(1, 'manager');
      expect((cubit.state as InstitutionTeamLoaded).members.first.role, 'manager');
      await cubit.remove(1);
      final s = cubit.state as InstitutionTeamLoaded;
      expect(s.members.map((m) => m.id), [2]);
      expect(s.message, 'institution_member_removed');

      repo.failNext = true;
      expect(await cubit.remove(2), isFalse);
      expect((cubit.state as InstitutionTeamLoaded).members, hasLength(1));
      await cubit.close();
    });

    test('InstitutionCreditsCubit loads the balance', () async {
      final cubit = InstitutionCreditsCubit(repository: _FakeRepo());
      await cubit.load();
      expect((cubit.state as InstitutionCreditsLoaded).credits.balance, 40);
      await cubit.close();
    });
  });
}
