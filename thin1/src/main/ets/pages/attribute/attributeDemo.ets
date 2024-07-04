import { ButtonAttributeModifier } from '../attribute/ButtonAttributeModifier'

/**
 * 动态属性设置，跨文件操作
 */

@Entry
@Component
struct attributeDemo {
  @State buttonModifier: ButtonAttributeModifier = new ButtonAttributeModifier()

  build() {

    Button('按钮')
      .attributeModifier(this.buttonModifier)
      .onClick(() => {
        this.buttonModifier.isDark = !this.buttonModifier.isDark
      })
      .width('50%')
      .height(50)
  }
}