package healthbar {
import common.BaseControl;

public class HealthBar extends BaseControl {

	private var m_healthBarView:HealthBarView = new HealthBarView();
	private var m_currentHealth:Number;

	public function HealthBar() {
		addChild(m_healthBarView);
	}

	public function SetHealth(health:Number):void {
		m_currentHealth = health;
		m_healthBarView.HealthBarText.text = String(Math.round(health));
		UpdateHealth()
	}

	public function UpdateHealth():void {
		var m_maxHealth:Number = 100;
		m_healthBarView.HealthBarInner.scaleY = m_currentHealth / m_maxHealth;
	}

	public function set Debug(health:Number):void {
		m_currentHealth = health;
		m_healthBarView.HealthBarText.text = String(Math.round(health));
		UpdateHealth();
	}

}
}
