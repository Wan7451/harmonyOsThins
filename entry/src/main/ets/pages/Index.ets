import { promptAction, router } from '@kit.ArkUI';
import { common, UIAbility, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN_NUMBER = 0x0001
const TAG = "Page/Index"

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private context = getContext(this) as common.UIAbilityContext
  a: string | null = null

  private startAbility(): void {
    //对象字面量
    let want: Want = {
      deviceId: "", // deviceId为空表示本设备
      bundleName: "com.example.myapplication",
      abilityName: "MyEntryAbility",
      moduleName: "entry", //moduleName在待启动的UIAbility属于不同的Module时添加
      parameters: {
        instanceKey: "aaaa",
        extraKey: "bbbbb"
      }
    }
    this.context.startAbilityForResult(want)
      .then((data) => {
        let info = data.want?.parameters?.info as string
        //对象字面量
        promptAction.showToast({
          message : info
        })
        hilog.info(DOMAIN_NUMBER, TAG, "startAbility success.")
      })
      .catch((err: BusinessError) => {
        hilog.info(DOMAIN_NUMBER, TAG, "startAbility failed.")
      })
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      Button() {
        Text("Next")
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
      }
      .type(ButtonType.Capsule)
      .margin({
        top: 20
      })
      .backgroundColor(Color.Blue)
      .width('30%')
      .height('10%')
      .onClick(() => {
        promptAction.showToast({
          message: $r('app.string.MyEntryAbility_label')
        })
        this.context.eventHub.emit("event1", "qqqqq", "wwwwww")
        this.startAbility()
        //router.pushUrl({ url: 'pages/Page22' })
      })
      if (this.a){
        Text($r('app.string.MyEntryAbility_desc'))
      }else {
        Button($r('app.string.module_desc'))
      }
    }
    .height('100%')
    .width('100%')
  }

  onPageShow(): void {
    hilog.info(DOMAIN_NUMBER,TAG,"onPageShow")
  }
  onPageHide(): void {
    hilog.info(DOMAIN_NUMBER,TAG,"onPageHide")
  }
  onBackPress(): boolean | void {
    hilog.info(DOMAIN_NUMBER,TAG,"onBackPress")
    return true
  }
}