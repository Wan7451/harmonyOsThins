/**
 * 2. 生命周期
 *
 * 页面生命周期，即被@Entry装饰的组件生命周期
 * onPageShow：页面每次显示时触发一次，包括路由过程、应用进入前台等场景。
 * onPageHide：页面每次隐藏时触发一次，包括路由过程、应用进入后台等场景。
 * onBackPress：当用户点击返回按钮时触发。
 *
 * 组件生命周期，即一般用@Component装饰的自定义组件的生命周期
 * aboutToAppear：组件即将出现时回调该接口，具体时机为在创建自定义组件的新实例后，在执行其build()函数之前执行。
 * onDidBuild：组件build()函数执行完成之后回调该接口，
 *    不建议在onDidBuild函数中更改状态变量、使用animateTo等功能，这可能会导致不稳定的UI表现。
 * aboutToDisappear：aboutToDisappear函数在自定义组件析构销毁之前执行。
 *    不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。
 *
 *
 * 不建议在生命周期aboutToDisappear内使用async await，
 * 如果在生命周期的aboutToDisappear使用异步操作（Promise或者回调方法），
 * 自定义组件将被保留在Promise的闭包中，直到回调方法被执行完，这个行为阻止了自定义组件的垃圾回收。
 *
 *
 */
import { common } from '@kit.AbilityKit';
import uiObserver from '@ohos.arkui.observer';
import observer from '@ohos.arkui.observer';

const TAG = "[LifeCycle]"


@Entry
@Component
struct LifeCycle {
  onPageShow(): void {
    console.log(TAG, "Entry", "onPageShow")
  }

  onPageHide(): void {
    console.log(TAG, "Entry", "onPageHide")
  }

  onBackPress(): boolean | void {
    console.log(TAG, "Entry", "onBackPress")
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    context.terminateSelf()
    // 返回true表示页面自己处理返回逻辑，不进行页面路由；
    // 返回false表示使用默认的路由返回逻辑，不设置返回值按照false处理
    return true
  }

  aboutToAppear() {
    console.log(TAG, "Entry", 'aboutToAppear');
  }

  onDidBuild() {
    console.log(TAG, "Entry", 'onDidBuild');
  }

  aboutToDisappear() {
    console.log(TAG, "Entry", 'aboutToDisappear');
  }

  @State isShow: boolean = true
  @State hint: string = '隐藏'

  build() {
    Column() {
      Button(this.hint)
        .width(100)
        .height(100)
        .onClick(() => {
          this.isShow = !this.isShow
          if (this.isShow) {
            this.hint = "隐藏"
          } else {
            this.hint = "显示"
          }
        })
      if (this.isShow) {
        CustomLifeComponent({ message: '按钮' }) {
          Text("A").backgroundColor(Color.Black)
          Text("B").backgroundColor(Color.Blue)
          Text("C").backgroundColor(Color.Brown)
          Text("D").backgroundColor(Color.Black)
        }
      }
    }
  }
}


@Component
struct CustomLifeComponent {
  listener: (info: observer.RouterPageInfo) => void = (info: observer.RouterPageInfo) => {
    let routerInfo: observer.RouterPageInfo | undefined = this.queryRouterPageInfo();
    if (info.pageId == routerInfo?.pageId) {
      if (info.state == observer.RouterPageState.ON_PAGE_SHOW) {
        console.log(TAG, "Component", `onPageShow`);
      } else if (info.state == observer.RouterPageState.ON_PAGE_HIDE) {
        console.log(TAG, "Component", `onPageHide`);
      }
    }
  }

  aboutToAppear(): void {
    console.log(TAG, "Component", "aboutToAppear")
    //todo 文档对不上，用我这个
    uiObserver.on('routerPageUpdate', this.getUIContext(), this.listener)
  }

  onDidBuild(): void {
    console.log(TAG, "Component", "onDidBuild")
  }

  aboutToDisappear(): void {
    console.log(TAG, "Component", "aboutToDisappear")
    //todo 文档对不上，用我这个
    uiObserver.off('routerPageUpdate', this.getUIContext(), this.listener)
  }

  @Builder
  doNothingBuilder() {
  };

  //必须这么写，不然编译失败
  @BuilderParam builder: () => void = this.doNothingBuilder;
  @State startSize: number = 100;
  result: SizeResult = {
    width: 0,
    height: 0
  };

  /**
   * 组件每次布局时触发，计算子组件的尺寸，其执行时间先于onPlaceChildren。
   */
  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Measurable[], constraint: ConstraintSizeOptions): SizeResult {
    let size = 100;
    children.forEach((child) => {
      let result = child.measure({
        minWidth: size,
        minHeight: size,
        maxWidth: size,
        maxHeight: size
      })
      size += result.width / 2
    })
    this.result.width = 100;
    this.result.height = 400;
    return this.result;
  }

  /**
   * 组件每次布局时触发，设置子组件的起始位置。
   */
  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Layoutable[], constraint: ConstraintSizeOptions): void {
    let startPos = 300;
    children.forEach((child) => {
      let pos = startPos - child.measureResult.height
      child.layout({
        x: pos, y: pos
      })
    })
  }

  @State message: string = ""

  build() {
    Text(this.message)
      .width(100)
      .height(100)
      .margin(50)
      .backgroundColor(Color.Grey)
  }
}

/**
 * 自定义组件处于非激活状态时，状态变量将不响应更新，即@Watch不会调用，状态变量关联的节点不会刷新。
 * 通过freezeWhenInactive属性来决定是否使用冻结功能，不传参数时默认不使用。
 * 支持的场景有：页面路由，TabContent，LazyForEach，Navigation。
 */
@Component
struct CustomFreezeComponent {
  build() {
  }
}

