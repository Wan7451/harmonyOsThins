import { AbilityConstant, AbilityStage, Configuration, Want } from '@kit.AbilityKit';

const TAG = "wwww";

export default class MyAbilityStage extends AbilityStage {
  onCreate(): void {
    console.warn(TAG, "MyAbilityStage  onCreate");
  }

  onAcceptWant(want: Want): string {
    console.warn(TAG, "MyAbilityStage  onAcceptWant")

    if (want.abilityName === "MyEntryAbility") {
      if (want.parameters) {
        return `MyEntryAbility_${want.parameters.instanceKey}`
      }
    }

    return super.onAcceptWant(want);
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    console.warn(TAG, "MyAbilityStage  onConfigurationUpdate")
    //当系统全局配置发生变更时触发的事件，系统语言、深浅色等，配置项目前均定义在Configuration类中。
  }

  onMemoryLevel(level: AbilityConstant.MemoryLevel): void {
    //当系统调整内存时触发的事件。
    // 根据系统可用内存的变化情况，释放不必要的内存
  }
}