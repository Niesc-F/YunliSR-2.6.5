const std = @import("std");
const protocol = @import("protocol");
const Session = @import("Session.zig");
const Packet = @import("Packet.zig");
const avatar = @import("services/avatar.zig");
const gacha = @import("services/gacha.zig");
const item = @import("services/item.zig");
const battle = @import("services/battle.zig");
const login = @import("services/login.zig");
const lineup = @import("services/lineup.zig");
const misc = @import("services/misc.zig");
const mission = @import("services/mission.zig");
const pet = @import("services/pet.zig");
const scene = @import("services/scene.zig");
const chat = @import("services/chat.zig");

const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const CmdID = protocol.CmdID;

const log = std.log.scoped(.handlers);

const Action = *const fn (*Session, *const Packet, Allocator) anyerror!void;
const HandlerList = [_]struct { CmdID, Action }{
    .{ CmdID.CmdPlayerGetTokenCsReq, login.onPlayerGetToken },
    .{ CmdID.CmdPlayerLoginCsReq, login.onPlayerLogin },
    .{ CmdID.CmdPlayerHeartBeatCsReq, misc.onPlayerHeartBeat },
    .{ CmdID.CmdGetAvatarDataCsReq, avatar.onGetAvatarData },
    .{ CmdID.CmdGetMultiPathAvatarInfoCsReq, avatar.onGetMultiPathAvatarInfo },
    .{ CmdID.CmdGetBagCsReq, item.onGetBag },
    .{ CmdID.CmdChangeLineupLeaderCsReq, lineup.onChangeLineupLeader },
    .{ CmdID.CmdGetMissionStatusCsReq, mission.onGetMissionStatus },
    .{ CmdID.CmdGetCurLineupDataCsReq, lineup.onGetCurLineupData },
    .{ CmdID.CmdGetCurSceneInfoCsReq, scene.onGetCurSceneInfo },
    .{ CmdID.CmdSceneEntityMoveCsReq, scene.onSceneEntityMove },
    .{ CmdID.CmdStartCocoonStageCsReq, battle.onStartCocoonStage },
    .{ CmdID.CmdPVEBattleResultCsReq, battle.onPVEBattleResult },
    //.{ CmdID.CmdGetPhoneDataCsReq, profile.onGetPhoneData },
    //.{ CmdID.CmdSelectPhoneThemeCsReq, profile.onSelectPhoneTheme },
    //.{ CmdID.CmdSelectChatBubbleCsReq, profile.onSelectChatBubble },
    //.{ CmdID.CmdGetPlayerBoardDataCsReq, profile.onGetPlayerBoardData },
    //.{ CmdID.CmdSetDisplayAvatarCsReq, profile.onGetPlayerBoardData },
    //.{ CmdID.CmdSetSignatureCsReq, profile.onSetSignature },
    //.{ CmdID.CmdSetGameplayBirthdayCsReq, profile.onSetGameplayBirthday },
    //.{ CmdID.CmdSetAssistAvatarCsReq, profile.onGetPlayerBoardData },
    .{ CmdID.CmdGetTutorialCsReq, mission.onGetTutorialStatus },
    .{ CmdID.CmdGetTutorialGuideCsReq, mission.onGetGuideStatus },
    .{ CmdID.CmdReplaceLineupCsReq, lineup.onReplaceLineup },
    .{ CmdID.CmdGetFriendListInfoCsReq, chat.onGetFriendListInfo },
    //.{ CmdID.CmdSetLineupNameCsReq, lineup.onSetLineupName },
    .{ CmdID.CmdGetChatEmojiListCsReq, chat.onChatEmojiList },
    .{ CmdID.CmdGetPrivateChatHistoryCsReq, chat.onPrivateChatHistory },
    .{ CmdID.CmdSendMsgCsReq, chat.onSendMsg },
    .{ CmdID.CmdGetGachaInfoCsReq, gacha.onGetGachaInfo },
    .{ CmdID.CmdBuyGoodsCsReq, gacha.onBuyGoods },
    .{ CmdID.CmdGetShopListCsReq, gacha.onGetShopList },
    //.{ CmdID.CmdGetMailCsReq, mail.onGetMail },
    .{ CmdID.CmdGetQuestDataCsReq, mission.onGetQuestDataCsReq },
    //.{ CmdID.CmdSceneCastSkillCsReq, battle.onSceneCastSkill },
    //.{ CmdID.CmdSetHeadIconCsReq, profile.onSetHeadIcon },
    //.{ CmdID.CmdSceneCastSkillCostMpCsReq, scene.onSceneCastSkillCostMp },
    .{ CmdID.CmdExchangeHcoinCsReq, gacha.onExchangeHcoin },
    //.{ CmdID.CmdEnterSceneCsReq, scene.onEnterScene },
    .{ CmdID.CmdGetPetDataCsReq, pet.onGetPetData },
    .{ CmdID.CmdDoGachaCsReq, gacha.onDoGacha },
    .{ CmdID.CmdRecallPetCsReq, pet.onRecallPet },
    .{ CmdID.CmdSummonPetCsReq, pet.onSummonPet },
    //.{ CmdID.CmdGetSceneMapInfoScRsp, scene.onGetSceneMapInfo },
    //.{ CmdID.CmdEnterSectionCsReq, scene.onEnterSection },
};

const DummyCmdList = [_]struct { CmdID, CmdID }{
    .{ CmdID.CmdGetLevelRewardTakenListCsReq, CmdID.CmdGetLevelRewardTakenListScRsp },
    .{ CmdID.CmdGetRogueScoreRewardInfoCsReq, CmdID.CmdGetRogueScoreRewardInfoScRsp },
    //.{ CmdID.CmdGetGachaInfoCsReq, CmdID.CmdGetGachaInfoScRsp },
    .{ CmdID.CmdQueryProductInfoCsReq, CmdID.CmdQueryProductInfoScRsp },
    //.{ CmdID.CmdGetQuestDataCsReq, CmdID.CmdGetQuestDataScRsp },
    .{ CmdID.CmdGetQuestRecordCsReq, CmdID.CmdGetQuestRecordScRsp },
    .{ CmdID.CmdGetFriendListInfoCsReq, CmdID.CmdGetFriendListInfoScRsp },
    .{ CmdID.CmdGetFriendApplyListInfoCsReq, CmdID.CmdGetFriendApplyListInfoScRsp },
    .{ CmdID.CmdGetCurAssistCsReq, CmdID.CmdGetCurAssistScRsp },
    .{ CmdID.CmdGetRogueHandbookDataCsReq, CmdID.CmdGetRogueHandbookDataScRsp },
    .{ CmdID.CmdGetDailyActiveInfoCsReq, CmdID.CmdGetDailyActiveInfoScRsp },
    .{ CmdID.CmdGetFightActivityDataCsReq, CmdID.CmdGetFightActivityDataScRsp },
    .{ CmdID.CmdGetMultipleDropInfoCsReq, CmdID.CmdGetMultipleDropInfoScRsp },
    .{ CmdID.CmdGetPlayerReturnMultiDropInfoCsReq, CmdID.CmdGetPlayerReturnMultiDropInfoScRsp },
    .{ CmdID.CmdGetShareDataCsReq, CmdID.CmdGetShareDataScRsp },
    .{ CmdID.CmdGetTreasureDungeonActivityDataCsReq, CmdID.CmdGetTreasureDungeonActivityDataScRsp },
    .{ CmdID.CmdPlayerReturnInfoQueryCsReq, CmdID.CmdPlayerReturnInfoQueryScRsp },
    .{ CmdID.CmdGetBasicInfoCsReq, CmdID.CmdGetBasicInfoScRsp },
    //.{ CmdID.CmdGetPlayerBoardDataCsReq, CmdID.CmdGetPlayerBoardDataScRsp },
    .{ CmdID.CmdGetAllLineupDataCsReq, CmdID.CmdGetAllLineupDataScRsp },
    .{ CmdID.CmdGetActivityScheduleConfigCsReq, CmdID.CmdGetActivityScheduleConfigScRsp },
    .{ CmdID.CmdGetMissionDataCsReq, CmdID.CmdGetMissionDataScRsp },
    .{ CmdID.CmdGetMissionEventDataCsReq, CmdID.CmdGetMissionEventDataScRsp },
    .{ CmdID.CmdGetChallengeCsReq, CmdID.CmdGetChallengeScRsp },
    .{ CmdID.CmdGetCurChallengeCsReq, CmdID.CmdGetCurChallengeScRsp },
    .{ CmdID.CmdGetRogueInfoCsReq, CmdID.CmdGetRogueInfoScRsp },
    .{ CmdID.CmdGetExpeditionDataCsReq, CmdID.CmdGetExpeditionDataScRsp },
    .{ CmdID.CmdGetJukeboxDataCsReq, CmdID.CmdGetJukeboxDataScRsp },
    .{ CmdID.CmdSyncClientResVersionCsReq, CmdID.CmdSyncClientResVersionScRsp },
    .{ CmdID.CmdDailyFirstMeetPamCsReq, CmdID.CmdDailyFirstMeetPamScRsp },
    .{ CmdID.CmdGetMuseumInfoCsReq, CmdID.CmdGetMuseumInfoScRsp },
    .{ CmdID.CmdGetLoginActivityCsReq, CmdID.CmdGetLoginActivityScRsp },
    .{ CmdID.CmdGetRaidInfoCsReq, CmdID.CmdGetRaidInfoScRsp },
    .{ CmdID.CmdGetTrialActivityDataCsReq, CmdID.CmdGetTrialActivityDataScRsp },
    .{ CmdID.CmdGetBoxingClubInfoCsReq, CmdID.CmdGetBoxingClubInfoScRsp },
    .{ CmdID.CmdGetNpcStatusCsReq, CmdID.CmdGetNpcStatusScRsp },
    .{ CmdID.CmdTextJoinQueryCsReq, CmdID.CmdTextJoinQueryScRsp },
    .{ CmdID.CmdGetSpringRecoverDataCsReq, CmdID.CmdGetSpringRecoverDataScRsp },
    .{ CmdID.CmdGetChatFriendHistoryCsReq, CmdID.CmdGetChatFriendHistoryScRsp },
    .{ CmdID.CmdGetSecretKeyInfoCsReq, CmdID.CmdGetSecretKeyInfoScRsp },
    .{ CmdID.CmdGetVideoVersionKeyCsReq, CmdID.CmdGetVideoVersionKeyScRsp },
    .{ CmdID.CmdGetCurBattleInfoCsReq, CmdID.CmdGetCurBattleInfoScRsp },
    //.{ CmdID.CmdGetPhoneDataCsReq, CmdID.CmdGetPhoneDataScRsp },
    .{ CmdID.CmdPlayerLoginFinishCsReq, CmdID.CmdPlayerLoginFinishScRsp },
    .{ CmdID.CmdGetMarkItemListCsReq, CmdID.CmdGetMarkItemListScRsp },
    .{ CmdID.CmdGetAllServerPrefsDataCsReq, CmdID.CmdGetAllServerPrefsDataScRsp },
    .{ CmdID.CmdGetRogueCommonDialogueDataCsReq, CmdID.CmdGetRogueCommonDialogueDataScRsp },
    .{ CmdID.CmdGetRogueEndlessActivityDataCsReq, CmdID.CmdGetRogueEndlessActivityDataScRsp },
    .{ CmdID.CmdGetMainMissionCustomValueCsReq, CmdID.CmdGetMainMissionCustomValueScRsp },
    .{ CmdID.CmdGetAssistHistoryCsReq, CmdID.CmdGetAssistHistoryScRsp },
    .{ CmdID.CmdRogueTournQueryCsReq, CmdID.CmdRogueTournQueryScRsp },
    .{ CmdID.CmdGetBattleCollegeDataCsReq, CmdID.CmdGetBattleCollegeDataScRsp },
    .{ CmdID.CmdGetHeartDialInfoCsReq, CmdID.CmdGetHeartDialInfoScRsp },
    .{ CmdID.CmdHeliobusActivityDataCsReq, CmdID.CmdHeliobusActivityDataScRsp },
    .{ CmdID.CmdGetEnteredSceneCsReq, CmdID.CmdGetEnteredSceneScRsp },
    .{ CmdID.CmdGetAetherDivideInfoCsReq, CmdID.CmdGetAetherDivideInfoScRsp },
    .{ CmdID.CmdGetMapRotationDataCsReq, CmdID.CmdGetMapRotationDataScRsp },
    .{ CmdID.CmdGetRogueCollectionCsReq, CmdID.CmdGetRogueCollectionScRsp },
    .{ CmdID.CmdGetRogueExhibitionCsReq, CmdID.CmdGetRogueExhibitionScRsp },
    .{ CmdID.CmdGetNpcMessageGroupCsReq, CmdID.CmdGetNpcMessageGroupScRsp },
    .{ CmdID.CmdGetFriendLoginInfoCsReq, CmdID.CmdGetFriendLoginInfoScRsp },
    .{ CmdID.CmdGetChessRogueNousStoryInfoCsReq, CmdID.CmdGetChessRogueNousStoryInfoScRsp },
    .{ CmdID.CmdCommonRogueQueryCsReq, CmdID.CmdCommonRogueQueryScRsp },
    .{ CmdID.CmdGetStarFightDataCsReq, CmdID.CmdGetStarFightDataScRsp },
    .{ CmdID.CmdEvolveBuildQueryInfoCsReq, CmdID.CmdEvolveBuildQueryInfoScRsp },
    .{ CmdID.CmdGetAlleyInfoCsReq, CmdID.CmdGetAlleyInfoScRsp },
    .{ CmdID.CmdGetAetherDivideChallengeInfoCsReq, CmdID.CmdGetAetherDivideChallengeInfoScRsp },
    .{ CmdID.CmdGetStrongChallengeActivityDataCsReq, CmdID.CmdGetStrongChallengeActivityDataScRsp },
    .{ CmdID.CmdGetOfferingInfoCsReq, CmdID.CmdGetOfferingInfoScRsp },
    .{ CmdID.CmdClockParkGetInfoCsReq, CmdID.CmdClockParkGetInfoScRsp },
    .{ CmdID.CmdGetGunPlayDataCsReq, CmdID.CmdGetGunPlayDataScRsp },
    .{ CmdID.CmdSpaceZooDataCsReq, CmdID.CmdSpaceZooDataScRsp },
    .{ CmdID.CmdGetUnlockTeleportCsReq, CmdID.CmdGetUnlockTeleportScRsp },
    .{ CmdID.CmdTravelBrochureGetDataCsReq, CmdID.CmdTravelBrochureGetDataScRsp },
    .{ CmdID.CmdRaidCollectionDataCsReq, CmdID.CmdRaidCollectionDataScRsp },
    //.{ CmdID.CmdGetChatEmojiListCsReq, CmdID.CmdGetChatEmojiListScRsp },
    .{ CmdID.CmdGetTelevisionActivityDataCsReq, CmdID.CmdGetTelevisionActivityDataScRsp },
    .{ CmdID.CmdGetTrainVisitorRegisterCsReq, CmdID.CmdGetTrainVisitorRegisterScRsp },
    .{ CmdID.CmdGetLoginChatInfoCsReq, CmdID.CmdGetLoginChatInfoScRsp },
    .{ CmdID.CmdGetFeverTimeActivityDataCsReq, CmdID.CmdGetFeverTimeActivityDataScRsp },
    .{ CmdID.CmdGetAllSaveRaidCsReq, CmdID.CmdGetAllSaveRaidScRsp },
    .{ CmdID.CmdGetPlayerDetailInfoCsReq, CmdID.CmdGetPlayerDetailInfoScRsp },
    .{ CmdID.CmdGetFriendBattleRecordDetailCsReq, CmdID.CmdGetFriendBattleRecordDetailScRsp },
    .{ CmdID.CmdGetFriendDevelopmentInfoCsReq, CmdID.CmdGetFriendDevelopmentInfoScRsp },
    .{ CmdID.CmdFinishTalkMissionCsReq, CmdID.CmdFinishTalkMissionScRsp },
    .{ CmdID.CmdRogueTournGetPermanentTalentInfoCsReq, CmdID.CmdRogueTournGetPermanentTalentInfoScRsp },
    .{ CmdID.CmdChessRogueQueryCsReq, CmdID.CmdChessRogueQueryScRsp },
    .{ CmdID.CmdGetTrackPhotoActivityDataCsReq, CmdID.CmdGetTrackPhotoActivityDataScRsp },
    .{ CmdID.CmdGetSwordTrainingDataCsReq, CmdID.CmdGetSwordTrainingDataScRsp },
    .{ CmdID.CmdGetSummonActivityDataCsReq, CmdID.CmdGetSummonActivityDataScRsp },
    .{ CmdID.CmdMatchThreeGetDataCsReq, CmdID.CmdMatchThreeGetDataScRsp },
    .{ CmdID.CmdGetDrinkMakerDataCsReq, CmdID.CmdGetDrinkMakerDataScRsp },
    .{ CmdID.CmdUpdateServerPrefsDataCsReq, CmdID.CmdUpdateServerPrefsDataScRsp },
    //.{ CmdID.CmdGetShopListCsReq, CmdID.CmdGetShopListScRsp },
    .{ CmdID.CmdUpdateTrackMainMissionIdCsReq, CmdID.CmdUpdateTrackMainMissionIdScRsp },
    .{ CmdID.CmdRelicRecommendCsReq, CmdID.CmdRelicRecommendScRsp },
    //.{ CmdID.CmdEnterSectionCsReq, CmdID.CmdEnterSectionScRsp },
    .{ CmdID.CmdRogueArcadeGetInfoCsReq, CmdID.CmdRogueArcadeGetInfoScRsp },
    //.{ CmdID.CmdGetPetDataCsReq, CmdID.CmdGetPetDataScRsp },
    .{ CmdID.CmdGetFightFestDataCsReq, CmdID.CmdGetFightFestDataScRsp },
    .{ CmdID.CmdDifficultyAdjustmentGetDataCsReq, CmdID.CmdDifficultyAdjustmentGetDataScRsp },
    //.{ CmdID.CmdGetMailCsReq, CmdID.CmdGetMailScRsp },
    //.{ CmdID.CmdGetTutorialCsReq, CmdID.CmdGetTutorialScRsp },
    //.{ CmdID.CmdGetTutorialGuideCsReq, CmdID.CmdGetTutorialGuideScRsp },
    .{ CmdID.CmdSetClientPausedCsReq, CmdID.CmdSetClientPausedScRsp },
    .{ CmdID.CmdGetSceneMapInfoCsReq, CmdID.CmdGetSceneMapInfoScRsp },
    .{ CmdID.CmdGetFirstTalkNpcCsReq, CmdID.CmdGetFirstTalkNpcScRsp },
    .{ CmdID.CmdGetFriendRecommendListInfoCsReq, CmdID.CmdGetFriendRecommendListInfoScRsp },
    .{ CmdID.CmdGetRecyleTimeCsReq, CmdID.CmdGetRecyleTimeScRsp },
    .{ CmdID.CmdGetMaterialSubmitActivityDataCsReq, CmdID.CmdGetMaterialSubmitActivityDataScRsp },
    .{ CmdID.CmdRogueTournGetCurRogueCocoonInfoCsReq, CmdID.CmdRogueTournGetCurRogueCocoonInfoScRsp },
    .{ CmdID.CmdRogueMagicQueryCsReq, CmdID.CmdRogueMagicQueryScRsp },
    .{ CmdID.CmdMusicRhythmDataCsReq, CmdID.CmdMusicRhythmDataScRsp },
};

const SuppressLogList = [_]CmdID{CmdID.CmdSceneEntityMoveCsReq};

pub fn handle(session: *Session, packet: *const Packet) !void {
    var arena = ArenaAllocator.init(session.allocator);
    defer arena.deinit();

    const cmd_id: CmdID = @enumFromInt(packet.cmd_id);

    inline for (HandlerList) |handler| {
        if (handler[0] == cmd_id) {
            try handler[1](session, packet, arena.allocator());
            if (!std.mem.containsAtLeast(CmdID, &SuppressLogList, 1, &[_]CmdID{cmd_id})) {
                log.debug("packet {} was handled", .{cmd_id});
            }
            return;
        }
    }

    inline for (DummyCmdList) |pair| {
        if (pair[0] == cmd_id) {
            try session.send_empty(pair[1]);
            return;
        }
    }

    log.warn("packet {} was ignored", .{cmd_id});
}
