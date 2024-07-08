/**
 * @AnimatableExtend装饰器：定义可动画属性   大白话：自定义不支持的属性动画
 *
 *
 * @AnimatableExtend装饰器用于自定义[可动画的属性]方法，在这个属性方法中修改组件[不可动画的属性]。
 * 在动画执行过程时，通过逐帧回调函数修改[不可动画属性]值，让[不可动画属性]也能实现动画效果。
 *
 *
 * 可动画属性：
 *    如果一个属性方法在animation属性前调用，改变这个属性的值可以生效animation属性的动画效果，这个属性称为可动画属性。
 *    比如height、width、backgroundColor、translate属性，Text组件的fontSize属性等。
 *
 * 不可动画属性：
 *    如果一个属性方法在animation属性前调用，改变这个属性的值不能生效animation属性的动画效果，这个属性称为不可动画属性。
 *    比如Polyline组件的points属性等。
 * todo 回头再看
 */

@Entry
@Component
struct EAnimatableDecorator {
  build() {

    Text('默认支持的属性动画')
      .width(200)
      .animation({
        duration: 10000,
        delay: 100,
        curve: "ease"
      })

  }
}