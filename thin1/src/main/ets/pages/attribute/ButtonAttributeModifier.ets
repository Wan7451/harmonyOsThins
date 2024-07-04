/**
 * 按钮通用属性
 */
export class ButtonAttributeModifier implements AttributeModifier<ButtonAttribute> {
  isDark: boolean = false

  applyNormalAttribute(instance: ButtonAttribute): void {
    if (this.isDark) {
      instance.backgroundColor(Color.Black)
    } else {
      instance.backgroundColor(Color.Red)
    }
  }
}