import { router } from '@kit.ArkUI';
import { common, UIAbility } from '@kit.AbilityKit';

@Entry
@Component
struct Page22 {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('Page22HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      Button() {
        Text('back')
      }.onClick(() => {
        let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
        let result: common.AbilityResult = {
          resultCode: 0,
          want: {
            parameters: {
              info: "22222222222"
            }
          }
        }
        context.terminateSelfWithResult(result, (err) => {

        })
      })
    }
    .height('100%')
    .width('100%')
  }
}