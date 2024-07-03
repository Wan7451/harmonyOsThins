import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN_NUMBER = 0xFFF0
const TAG = "[EntryAbility]"

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    let eventHub = this.context.eventHub;
    eventHub.on("event1", (data1: string, data2: string) => {

      hilog.info(DOMAIN_NUMBER,TAG,`event1 ${data1} ${data2}`)

    })
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  }

  onDestroy(): void {
    this.context.eventHub.off("event1")
    // 系统资源的释放、数据的保存等
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    //首页
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });

    windowStage.on('windowStageEvent', (data) => {
      let stageWindowType = data;
      switch (stageWindowType) {
        case window.WindowStageEventType.SHOWN:
          console.log('windowStage show');
          break;
        case window.WindowStageEventType.HIDDEN:
          console.log('windowStage hidden');
          break;
        case window.WindowStageEventType.ACTIVE:  // 获焦状态
          console.log('windowStage active');
          break;
        case window.WindowStageEventType.INACTIVE:  // 失焦状态
          console.log('windowStage inactive');
          break;


      }
    })

  }

  onWindowStageWillDestroy(windowStage: window.WindowStage): void {
    //释放通过windowStage对象获取的资源
    console.error("Ability onWindowStageWillDestroy")
  }

  onWindowStageDestroy(): void {
    // 释放UI资源
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    //在UIAbility的UI可见之前
    // 申请系统需要的资源，或者重新申请在onBackground()中释放的资源
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    //在UIAbility的UI完全不可见之后
    // 释放UI不可见时无用的资源，或者在此回调中执行较为耗时的操作
    // 例如状态保存等
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
