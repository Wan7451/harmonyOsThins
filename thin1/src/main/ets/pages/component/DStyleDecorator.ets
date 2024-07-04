import { Color } from '@kit.ArkGraphics3D';
import { promptAction } from '@kit.ArkUI';

/**
 * @Styles装饰器：定义组件重用样式，用于快速定义并复用自定义样式。
 *
 * @Styles装饰器可以将多条样式设置提炼成一个方法，直接在组件声明的位置调用。
 * 通过@Styles装饰器可以快速定义并复用自定义样式。
 *
 *
 * 1. 当前@Styles仅支持通用属性和通用事件。
 * 2. @Styles方法不支持参数
 * 3. @Styles可以定义在组件内或全局，在全局定义时需在方法名前面添加function关键字，组件内定义时则不需要添加function关键字。
 *      和 @Builder方法类型
 * 4. 只能在当前文件内使用，不支持export。如果要实现跨文件操作的功能，可以参考使用动态属性设置。
 * 5. 定义在组件内的@Styles可以通过this访问组件的常量和状态变量，并可以在@Styles里通过事件来改变状态变量的值
 * 6. 组件内@Styles的优先级高于全局@Styles。
 *
 *
 * @Extend，用于扩展原生组件样式。
 *
 * 1. @Extend仅支持在全局定义，不支持在组件内部定义。
 * 2. @Extend支持封装指定组件的私有属性、私有事件和自身定义的全局方法。
 * 3. @Extend装饰的方法支持参数，开发者可以在调用时传递参数，调用遵循TS方法传值调用。
 * 4. @Extend装饰的方法的参数可以为function，作为Event事件的句柄。
 * 5. @Extend的参数可以为状态变量，当状态变量改变时，UI可以正常的被刷新渲染。
 *
 *
 *
 * stateStyles（又称为：多态样式）。
 * stateStyles可以依据组件的内部状态的不同，快速设置不同样式。
 *
 * ArkUI提供以下五种状态：
 *    - focused：获焦态。
 *    - normal：正常态。
 *    - pressed：按压态。
 *    - disabled：不可用态。
 *    - selected10+：选中态。
 *
 */
@Entry
@Component
struct DStyleDecorator {
  @State label: string = "this is a label"
  @State fontSize: number = 30

  //组件内@Styles的优先级高于全局@Styles。
  @Styles
  generalStyle(){
    .width('50%')
    .height(100)
    .backgroundColor(Color.Orange)
    .onClick(() => {
      promptAction.showToast({
        message: "内部generalStyle"
      })
      this.label = 'this is a button'
      promptAction.showDialog({
        message: "this is a dialog"
      })
      this.fontSize = this.fontSize + 1
    })
  }

  @Styles
  normalStyle() {
    .backgroundColor(Color.Gray)
  }

  @Styles
  pressedStyle() {
    .backgroundColor(Color.Red)
  }

  build() {

    Column() {
      Text(this.label)
        .titleStyle(Color.Green, this.fontSize, () => {

        })
        .generalStyle()
        .stateStyles({
          normal: this.generalStyle, //这里没有括号
          pressed: generalStyle, //这里没有括号
        })
    }
  }
}


@Styles
function generalStyle() {
  .width('100%')
  .height(100)
  .backgroundColor(Color.Pink)
  .onClick(() => {
    promptAction.showToast({
      message: "globalStyle"
    })
  })
}

@Extend(Text)
function titleStyle(color: ResourceColor, size: number, onClock: () => void) {
  .fontColor(color)
  .fontSize(size)
  .onClick(onClock)
}