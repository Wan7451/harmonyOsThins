/**
 * Environment：设备环境查询
 *
 * Environment是ArkUI框架在应用程序启动时创建的单例对象。它为AppStorage提供了一系列描述应用程序运行状态的属性。
 * Environment的所有属性都是不可变的（即应用不可写入），所有的属性都是简单类型。
 *
 * accessibilityEnabled      boolean          获取无障碍屏幕读取是否启用。
 * colorMode                ColorMode        色彩模型类型：选项为ColorMode.LIGHT: 浅色，ColorMode.DARK: 深色。
 * fontScale                number          字体大小比例，范围: [0.85, 1.45]。
 * fontWeightScale          number          字体粗细程度，范围: [0.6, 1.6]。
 * layoutDirection          LayoutDirection  布局方向类型：包括LayoutDirection.LTR: 从左到右，LayoutDirection.RTL: 从右到左。
 * languageCode              string          当前系统语言值，取值必须为小写字母, 例如zh。
 *
 *
 * 设备环境到Component的更新链：Environment --> AppStorage -->Component。
 *
 *
 * 限制条件
 *
 * Environment和UIContext相关联，需要在UIContext明确的时候才可以调用。
 * 可以通过在runScopedTask里明确上下文。如果没有在UIContext明确的地方调用，
 * 将导致无法查询到设备环境数据。
 */

//将设备的语言code存入AppStorage，默认值为en
Environment.envProp('languageCode', 'en');

@Entry
@Component
struct IEnvironment {
  @StorageProp('languageCode') languageCode: string = 'en';

  build() {

    Column() {
      // 输出当前设备的languageCode
      Text(this.languageCode)
    }
  }
}

function get(){
  // 使用Environment.EnvProp将设备运行languageCode存入AppStorage中；
  Environment.envProp('languageCode', 'en');
  // 从AppStorage获取单向绑定的languageCode的变量
  const lang: SubscribedAbstractProperty<string> = AppStorage.prop('languageCode');

  if (lang.get() === 'zh') {
    console.info('你好');
  } else {
    console.info('Hello!');
  }
}